using System;
using System.IO;
using System.Security.Permissions;
using System.Web;
using Microsoft.Office.Server.Search.Query;
using Microsoft.Office.Server.Search.WebControls;
using Microsoft.SharePoint.Security;
using Microsoft.SharePoint.WebControls;

namespace Chaholl.SharePoint.Search.WebParts
{
    [AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
     SharePointPermission(SecurityAction.LinkDemand, ObjectModel = true),
     AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
     SharePointPermission(SecurityAction.InheritanceDemand, ObjectModel = true)]
    public class MultiValueRefinementPanel : RefinementWebPart, IDesignTimeHtmlProvider
    {
        #region IDesignTimeHtmlProvider Members

        string IDesignTimeHtmlProvider.GetDesignTimeHtml()
        {
            return "Chaholl.com - Multi-Value Refinement Panel";
        }

        #endregion

        protected override void OnInit(EventArgs e)
        {
            bool xslNotSet = string.IsNullOrEmpty(base.Xsl);

            //OnInit sets a default value for xsl. We need to replace that with a new default hence the check before calling onInit
            base.OnInit(e);

            if (UseDefaultConfiguration || xslNotSet)
            {
                Stream stream =
                    GetType().Assembly.GetManifestResourceStream(
                        "Chaholl.SharePoint.Search.RefinementPanel.SampleStylesheet.xslt");
                if (stream != null)
                {
                    using (var rdr = new StreamReader(stream))
                    {
                        string xsl = rdr.ReadToEnd();

                        xsl = xsl.Replace("$SharePoint.Project.AssemblyFullName$", GetType().Assembly.FullName);

                        base.Xsl = xsl;
                    }
                }
            }
        }

        public override string GetDefaultConfiguration(Location location)
        {
            Stream stream =
                GetType().Assembly.GetManifestResourceStream(
                    "Chaholl.SharePoint.Search.RefinementPanel.FilterCategoryDefinition.xml");

            if (stream != null)
            {
                using (var rdr = new StreamReader(stream))
                {
                    string xml = rdr.ReadToEnd();
                    xml = xml.Replace("$SharePoint.Project.AssemblyFullName$", GetType().Assembly.FullName);

                    return xml;
                }
            }
            return null;
        }
    }
}