using System;
using System.Collections.Specialized;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using Microsoft.Office.Server.Search.WebControls;

namespace Chaholl.SharePoint.Search.WebParts
{
    internal class MultiValueRefinementDataElement : RefinementDataElement
    {
        private const string CATEGORY_REGEX =
            "({0}(?<Operator>:|>|<|<=|>=|=)\"(?<FilterValue>([^\"]|\"\")*)\"(\\s|$))|({0}(?<Operator>:|>|<|<=|>=|=)(?<FilterValue>[^\\s]*)(\\s|$))";

        private const string REFINEMENT_REGEX =
            "(((({0})(:|>|<|<=|>=|=)\"([^\"]|\"\")*\"))|((({0})(:|>|<|<=|>=|=)([^\\s]*))))((\\s+AND\\s+)(((({0})(:|>|<|<=|>=|=)\"([^\"]|\"\")*\"))|((({0})(:|>|<|<=|>=|=)([^\\s]*)))))*";

        private readonly bool _selectable;
        private string _url;

        public MultiValueRefinementDataElement(FilterCategory fc, string filterDisplayName, long filterValueCount,
                                               float filterValuePercentage)
            : base(filterDisplayName, filterValueCount, filterValuePercentage)
        {
            _selectable = BuildRefinementUrl(fc, filterDisplayName);
        }

        public MultiValueRefinementDataElement(FilterCategory fc, RefinementDataElement el)
            : base(el.FilterDisplayValue, el.FilterValueCount, el.FilterValuePercentage)
        {
            _selectable = BuildRefinementUrl(fc, el.FilterDisplayValue);
        }

        public MultiValueRefinementDataElement(FilterCategory fc)
            : base(string.Empty, 0, 0)
        {
            _selectable = BuildRefinementUrl(fc, string.Empty);
        }

        public bool Selectable
        {
            get { return _selectable; }
        }

        public string Url
        {
            get { return _url; }
        }

        protected bool BuildRefinementUrl(FilterCategory fc, string value)
        {
            string filteringProperty = fc.MappedProperty;
            bool notSelected;

            bool hasRefinement = (HttpContext.Current.Request.QueryString["r"] != null);

            string origFilter = !hasRefinement ? string.Empty : HttpContext.Current.Request.QueryString["r"];

            string filterString = origFilter;

            if (string.IsNullOrEmpty(value))
            {
                //Remove any filters for this category
                int num = filterString.Length;
                filterString = RemoveCategoryFromUrl(filterString, fc);
                //if teh value changed then all values were not selected
                notSelected = (filterString.Length != num);
            }
            else
            {
                #region Valid Value

                notSelected = false;
                string propertyValue = filteringProperty.ToLower() + ":\"" + value + "\"";

                if (!filterString.Contains(propertyValue))
                {
                    notSelected = true;
                }

                if (notSelected)
                {
                    var regex = new Regex(string.Format(REFINEMENT_REGEX, filteringProperty), RegexOptions.IgnoreCase);
                    MatchCollection matchs2 = regex.Matches(filterString);
                    var builder2 = new StringBuilder();
                    builder2.Append(" " + propertyValue);
                    foreach (Match match2 in matchs2)
                    {
                        builder2.Append(" AND ");
                        builder2.Append(match2.Value);
                    }
                    filterString = regex.Replace(filterString, string.Empty) + builder2;
                }
                else
                {
                    var builder = new StringBuilder();
                    var regex2 = new Regex(string.Format(CATEGORY_REGEX, filteringProperty), RegexOptions.IgnoreCase);
                    //get a list of values for this category
                    foreach (Match match in regex2.Matches(filterString))
                    {
                        if ((match != null) && !string.IsNullOrEmpty(match.Value))
                        {
                            string trimmedValue = match.Value.Trim();
                            if (trimmedValue != propertyValue)
                            {
                                if (builder.Length > 0)
                                {
                                    builder.Append(" AND ");
                                }
                                builder.Append(trimmedValue);
                            }
                        }
                    }
                    filterString = RemoveCategoryFromUrl(filterString, fc);
                    if (builder.Length > 0)
                    {
                        filterString = filterString + " " + builder;
                    }
                }

                #endregion
            }

            filterString = HttpUtility.UrlEncode(filterString.Trim());

            Uri request = HttpContext.Current.Request.Url;
            
            NameValueCollection queryString = HttpContext.Current.Request.QueryString;

            string originalUrl = Regex.Replace(request.OriginalString, @"\?.{0,}", string.Empty);
            string qs = string.Empty;

            foreach (string key in queryString.AllKeys)
            {
                if (key != "r")
                {
                    qs = qs + "&" + key + "=" + queryString[key];
                }
            }

            qs = qs + "&r=" + filterString;

            _url = originalUrl + "?" + qs.Substring(1);

            return notSelected;
        }

        private static string RemoveCategoryFromUrl(string currentUrl, FilterCategory fc)
        {
            string filteringProperty = fc.MappedProperty;

            string expression = string.Format(CultureInfo.InvariantCulture,
                                              fc.CustomFiltersConfiguration != null ? CATEGORY_REGEX : REFINEMENT_REGEX,
                                              new object[] { filteringProperty });
            var regex = new Regex(expression, RegexOptions.IgnoreCase);
            return regex.Replace(currentUrl, string.Empty);
        }
    }
}