using System.Collections.Generic;
using System.Linq;
using System.Xml;
using Microsoft.Office.Server.Search.WebControls;

namespace Chaholl.SharePoint.Search.WebParts
{
    internal class MultiValueFilterGenerator:RefinementFilterGenerator
    {
        public override List<XmlElement> GetRefinement(
             Dictionary<string, Dictionary<string, RefinementDataElement>> refinedData,
             XmlDocument filterXml,
             int maxFilterCats)
        {
            var result = new List<XmlElement>();

            foreach (FilterCategory category in _Categories)
            {
                long itemCount = 0L;

                Dictionary<string, RefinementDataElement> filterResults =
                    refinedData.ContainsKey(category.MappedProperty)
                        ? refinedData[category.MappedProperty]
                        : new Dictionary<string, RefinementDataElement>();

                var newResults = new Dictionary<string, MultiValueRefinementDataElement>();

                //rebuild results
                long resultSum = 0;
                foreach (RefinementDataElement item in filterResults.Values)
                {
                    string[] actual = item.FilterDisplayValue.Split(';');
                    foreach (string x in actual)
                    {
                        MultiValueRefinementDataElement element;
                        if (newResults.ContainsKey(x))
                        {
                            element = newResults[x];
                        }
                        else
                        {
                            element = new MultiValueRefinementDataElement(category, x, 0, 0);
                            newResults.Add(x, element);
                        }
                        element.FilterValueCount = element.FilterValueCount + item.FilterValueCount;
                        resultSum = resultSum + item.FilterValueCount;
                        itemCount = (itemCount + item.FilterValueCount);
                    }
                }


                if (itemCount >= category.MetadataThreshold && itemCount != 0)
                {
                    //Calculate precentages
                    foreach (var item in newResults.Values)
                    {
                        item.FilterValuePercentage = (float)item.FilterValueCount / resultSum;
                    }

                    //Order unselected items by percentage
                    IOrderedEnumerable<MultiValueRefinementDataElement> topResults =
                        newResults.Values.Where(i => i.Selectable).OrderBy(i => i.FilterValuePercentage);
                    IEnumerable<MultiValueRefinementDataElement> selectedItems =
                        newResults.Values.Where(i => i.Selectable == false);
                    IEnumerable<MultiValueRefinementDataElement> results =
                        selectedItems.Concat(topResults).Take(category.MaxNumberOfFilters);
                    XmlElement categoryElmt = BuildCategoryElement(category, filterXml);

                    //Add visible filters
                    categoryElmt.AppendChild(AddFilters(category, filterXml, results, category.NumberOfFiltersToDisplay,
                                                        "Filters", true));

                    if (results.Count() > category.NumberOfFiltersToDisplay)
                    {
                        //add all filters
                        //re-order by display name
                        results = results.OrderBy(i => i.FilterDisplayValue);
                        categoryElmt.AppendChild(AddFilters(category, filterXml, results, category.MaxNumberOfFilters,
                                                            "MoreFilters", true));
                    }

                    result.Add(categoryElmt);
                }
            }
            return result;
        }

        private XmlElement AddFilters(FilterCategory category,
                                      XmlDocument filterXml,
                                      IEnumerable<MultiValueRefinementDataElement> filters,
                                      int count,
                                      string rootName,
                                      bool addAllNode)
        {
            XmlElement containerElmt = filterXml.CreateElement(rootName);

            if (addAllNode)
            {
                var el = new MultiValueRefinementDataElement(category);

                containerElmt.AppendChild(GenerateFilterElement(filterXml,
                                                                TruncatedString(
                                                                    "Any " + category.Title, NumberOfCharsToDisplay),
                                                                el.Url, el.Selectable, "",
                                                                "",
                                                                "",
                                                                ""));
            }

            foreach (MultiValueRefinementDataElement item in filters.Take(count))
            {
                containerElmt.AppendChild(GenerateFilterElement(filterXml,
                                                                TruncatedString(item.FilterDisplayValue,
                                                                                NumberOfCharsToDisplay),
                                                                item.Url, item.Selectable, item.FilterDisplayValue,
                                                                item.FilterValueCount.ToString(),
                                                                item.FilterValuePercentage.ToString(),
                                                                ""));
            }
            return containerElmt;
        }

        private XmlElement BuildCategoryElement(FilterCategory category, XmlDocument filterXml)
        {
            XmlElement element = filterXml.CreateElement("FilterCategory");
            element.SetAttribute("Id", category.Id);
            element.SetAttribute("ConfigId", category.Id);
            element.SetAttribute("Type", category.FilterType);
            element.SetAttribute("DisplayName", TruncatedString(category.Title, NumberOfCharsToDisplay));
            element.SetAttribute("ManagedProperty", category.MappedProperty);
            element.SetAttribute("ShowMoreLink", category.ShowMoreLink);
            element.SetAttribute("FreeFormFilterHint", category.FreeFormFilterHint);
            element.SetAttribute("MoreLinkText", category.MoreLinkText);
            element.SetAttribute("LessLinkText", category.LessLinkText);
            element.SetAttribute("ShowCounts", category.ShowCounts);
            return element;
        }

        private static XmlElement GenerateFilterElement(XmlDocument filterXml,
                                                        string truncatedFilterDisplayValue,
                                                        string url,
                                                        bool selectable,
                                                        string filterTooltip,
                                                        string count,
                                                        string percentage,
                                                        string filterIndentation)
        {
            XmlElement element2 = filterXml.CreateElement("Filter");
            XmlElement newChild = filterXml.CreateElement("Value");
            newChild.InnerText = truncatedFilterDisplayValue;
            element2.AppendChild(newChild);
            newChild = filterXml.CreateElement("Tooltip");
            newChild.InnerText = filterTooltip;
            element2.AppendChild(newChild);
            newChild = filterXml.CreateElement("Url");
            newChild.InnerText = url;
            element2.AppendChild(newChild);
            newChild = filterXml.CreateElement("Selection");
            newChild.InnerText = selectable ? "Deselected" : "Selected";
            element2.AppendChild(newChild);
            newChild = filterXml.CreateElement("Count");
            newChild.InnerText = count;
            element2.AppendChild(newChild);
            newChild = filterXml.CreateElement("Percentage");
            newChild.InnerText = percentage;
            element2.AppendChild(newChild);
            if (!string.IsNullOrEmpty(filterIndentation))
            {
                newChild = filterXml.CreateElement("Indentation");
                newChild.InnerText = filterIndentation;
                element2.AppendChild(newChild);
            }
            return element2;
        }
    }
}
