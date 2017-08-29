<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ddwrt="http://schemas.microsoft.com/WebParts/v2/DataView/runtime">
  <xsl:output method="html" indent="no" />
  <xsl:param name="RefinementPanelCaption"></xsl:param>
  <xsl:param name="QueryId"></xsl:param>
  <xsl:param name="TagsCategoryId"></xsl:param>
  <xsl:param name="MetadataServiceUrl"></xsl:param>
  <xsl:param name="IsUIRightToLeft"></xsl:param>
  <xsl:param name="ApplyButtonText"></xsl:param>
  <xsl:param name="CancelButtonText"></xsl:param>
  <xsl:param name="CurrentLcid"></xsl:param>
  <xsl:param name="MoreLinkPanelIDSuffix"></xsl:param>
  <xsl:param name="IdPrefix" />
  <xsl:param name="IsDesignMode">True</xsl:param>
  <xsl:param name="RefineByHeading">Refinement</xsl:param>
  <xsl:param name="IsRTL">False</xsl:param>

  <xsl:template match="FilterPanel">
    <xsl:variable name="FilterCategories" select="FilterCategory" />
    <xsl:variable name="CategoryCount" select="count($FilterCategories)" />
    <xsl:if test="($CategoryCount &gt; 0)">
      <xsl:call-template name="FilterCategory">
        <xsl:with-param name="Categories" select="$FilterCategories" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="FilterCategory">
    <xsl:param name="Categories" />
    <xsl:if test="$RefinementPanelCaption != ''">
      <div class="ms-searchref-caption">
        <xsl:value-of select="$RefinementPanelCaption" />
      </div>
    </xsl:if>
    <xsl:for-each select="$Categories">
      <xsl:variable name="FilterCategoryId" select="concat(@Id,$IdPrefix)" />
      <xsl:variable name="TagsId" select="concat($TagsCategoryId,$IdPrefix)" />
      <xsl:variable name="ColumnId" select="substring(@Id,10)" />
      <xsl:variable name="FilterCategoryType" select="@Type" />
      <xsl:variable name="ManagedProperty" select="@ManagedProperty" />
      <xsl:variable name="SSPList" select="substring-before(CustomData/AssociateTermSets, '|')" />
      <xsl:variable name="TermSetList" select="substring-after(CustomData/AssociateTermSets, '|')" />
      <xsl:variable name="ShowMoreLink" select="translate(@ShowMoreLink,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
      <xsl:variable name="FreeFormFilterHint" select="@FreeFormFilterHint" />
      <xsl:variable name="MoreLinkText" select="@MoreLinkText" />
      <xsl:variable name="LessLinkText" select="@LessLinkText" />
      <xsl:variable name="ShowCounts" select="@ShowCounts" />
      <xsl:variable name="DisplayName" select="@DisplayName" />
      <xsl:variable name="ShowTaggingControl" select="@ShowTaggingControl" />
      <div class="ms-searchref-categoryname">
        <xsl:value-of select="$DisplayName" />
      </div>
      <ul class="ms-searchref-filters" id="TopFilters_{$FilterCategoryId}">
        <xsl:choose>
          <xsl:when test="$FilterCategoryType = 'Message'">
            <xsl:for-each select="Filters/Filter">
              <xsl:call-template name="FilterMessage">
                <xsl:with-param name="Value" select="Value" />
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="Filter">
              <xsl:with-param name="Filters" select="Filters/Filter" />
              <xsl:with-param name="ShowCounts" select="$ShowCounts" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </ul>
      <xsl:if test="$ShowMoreLink='TRUE'">
        <xsl:variable name="MoreFilters" select="MoreFilters/Filter" />
        <xsl:choose>
          <xsl:when test="$FilterCategoryId and ($FilterCategoryId != '') and ($FilterCategoryType = 'Chaholl.SharePoint.Search.WebParts.MultiValueFilterGenerator, $SharePoint.Project.AssemblyFullName$')">
            <xsl:variable name="MoreDivId" select="concat('RefinementMore_', $QueryId, $FilterCategoryId)" />
            <xsl:variable name="LessDivId" select="concat('RefinementLess_', $QueryId, $FilterCategoryId)" />
            <xsl:if test="$MoreFilters != ''">
              <a class="ms-searchref-more" href="javascript:{{}}" onclick="SearchEnsureSOD();ToggleRefMoreLessFilters(this, true);">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$MoreLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/more_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
              <ul class="ms-searchref-filters" id="MoreFilters_{$FilterCategoryId}" style="display:none">
                <xsl:call-template name="Filter">
                  <xsl:with-param name="Filters" select="$MoreFilters" />
                  <xsl:with-param name="ShowCounts" select="$ShowCounts" />
                </xsl:call-template>
              </ul>
              <a class="ms-searchref-more" href="javascript:{{}}" onclick="SearchEnsureSOD();ToggleRefMoreLessFilters(this, false);" style="display:none">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$LessLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/less_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$FilterCategoryId and ($FilterCategoryId != '') and ($FilterCategoryType = 'Microsoft.Office.Server.Search.WebControls.ManagedPropertyFilterGenerator')">
            <xsl:variable name="MoreDivId" select="concat('RefinementMore_', $QueryId, $FilterCategoryId)" />
            <xsl:variable name="LessDivId" select="concat('RefinementLess_', $QueryId, $FilterCategoryId)" />
            <xsl:if test="$MoreFilters != ''">
              <a class="ms-searchref-more" href="javascript:{{}}" onclick="SearchEnsureSOD();ToggleRefMoreLessFilters(this, true);">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$MoreLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/more_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
              <ul class="ms-searchref-filters" id="MoreFilters_{$FilterCategoryId}" style="display:none">
                <xsl:call-template name="Filter">
                  <xsl:with-param name="Filters" select="$MoreFilters" />
                  <xsl:with-param name="ShowCounts" select="$ShowCounts" />
                </xsl:call-template>
              </ul>
              <a class="ms-searchref-more" href="javascript:{{}}" onclick="SearchEnsureSOD();ToggleRefMoreLessFilters(this, false);" style="display:none">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$LessLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/less_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$FilterCategoryId and ($FilterCategoryId != '') and ($FilterCategoryType = 'Microsoft.Office.Server.Search.WebControls.TaxonomyFilterGenerator')">
            <xsl:variable name="IsTagsColumn" select="$FilterCategoryId = $TagsId" />
            <xsl:if test="$MoreFilters != ''">
              <a id="{$MoreLinkPanelIDSuffix}_{$FilterCategoryId}" href="javascript:{{}}" class="ms-searchref-more" onclick="SearchEnsureSOD();RenderTaggingControl('{$FilterCategoryId}', {$IsTagsColumn}, '{$SSPList}', '{$TermSetList}', '{$MetadataServiceUrl}', {$CurrentLcid}, '{$MoreLinkPanelIDSuffix}', '{$DisplayName}', {$ShowTaggingControl}, {$IsUIRightToLeft});">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$MoreLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/more_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
              <div style="display:none">
                <ul class="ms-searchref-filters" id="MoreFilters_{$FilterCategoryId}">
                  <xsl:call-template name="Filter">
                    <xsl:with-param name="Filters" select="MoreFilters/Filter" />
                    <xsl:with-param name="ShowCounts" select="$ShowCounts" />
                  </xsl:call-template>
                </ul>
                <div id="TaxonomyMoreControl_{$FilterCategoryId}">
                  <input id="MetadataHiddenInput_{$FilterCategoryId}" type="hidden" />
                  <div id="TaggingControl_{$FilterCategoryId}" class="ms-taxonomy"></div>
                  <img style="display:none" src="/_layouts/images/RTE2FIND.gif" class="ms-searchref-taxapply" align="right" alt="{$ApplyButtonText}" onclick="SearchEnsureSOD();var link=GetTaxonomyApplyFilterUrl('{$FilterCategoryId}','{$ColumnId}');if (link!='')window.location=link;" />
                </div>
              </div>
              <a style="display:none" class="ms-searchref-more" href="javascript:{{}}" onclick="SearchEnsureSOD();ToggleTaxonomyLessFilters(this);">
                <div class="ms-searchref-morelink">
                  <xsl:value-of select="$LessLinkText" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <img src="/_layouts/images/less_arrow.png" class="ms-searchref-moreicon" />
                </div>
              </a>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$FilterCategoryId and ($FilterCategoryId != '') and ($FilterCategoryType = 'Message')"></xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <div class="ms-searchref-catseparator">&#160;</div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="Filter">
    <xsl:param name="Filters" />
    <xsl:param name="ShowCounts" />
    <xsl:for-each select="$Filters">
      <xsl:variable name="Selection" select="Selection" />
      <xsl:choose>
        <xsl:when test="($Selection = 'Selected')">
          <xsl:call-template name="FilterLink">
            <xsl:with-param name="Url" select="Url" />
            <xsl:with-param name="UrlTooltip" select="Tooltip" />
            <xsl:with-param name="Value" select="Value" />
            <xsl:with-param name="FilterSelection" select="'ms-searchref-selected ms-searchref-removable'" />
            <xsl:with-param name="ShowCounts" select="$ShowCounts" />
            <xsl:with-param name="Count" select="Count" />
            <xsl:with-param name="Percentage" select="Percentage" />
            <xsl:with-param name="Indentation" select="Indentation" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="($Selection = 'Implied')">
          <xsl:call-template name="FilterLink">
            <xsl:with-param name="Url" select="Url" />
            <xsl:with-param name="UrlTooltip" select="Tooltip" />
            <xsl:with-param name="Value" select="Value" />
            <xsl:with-param name="FilterSelection" select="'ms-searchref-selected'" />
            <xsl:with-param name="ShowCounts" select="$ShowCounts" />
            <xsl:with-param name="Count" select="Count" />
            <xsl:with-param name="Percentage" select="Percentage" />
            <xsl:with-param name="Indentation" select="Indentation" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="FilterLink">
            <xsl:with-param name="Url" select="Url" />
            <xsl:with-param name="UrlTooltip" select="Tooltip" />
            <xsl:with-param name="Value" select="Value" />
            <xsl:with-param name="FilterSelection" select="'ms-searchref-unselected'" />
            <xsl:with-param name="ShowCounts" select="$ShowCounts" />
            <xsl:with-param name="Count" select="Count" />
            <xsl:with-param name="Percentage" select="Percentage" />
            <xsl:with-param name="Indentation" select="Indentation" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="FilterLink">
    <xsl:param name="Url" />
    <xsl:param name="UrlTooltip" />
    <xsl:param name="Value" />
    <xsl:param name="FilterSelection" />
    <xsl:param name="ShowCounts" />
    <xsl:param name="Count" />
    <xsl:param name="Percentage" />
    <xsl:param name="Indentation" />
    <xsl:variable name="SecureUrl">
      <xsl:call-template name="GetSecureUrl">
        <xsl:with-param name="Url" select="$Url" />
      </xsl:call-template>
    </xsl:variable>
    <li class="ms-searchref-filter {$FilterSelection}">
      <xsl:if test="($Indentation = '1')">
        <span class="ms-searchref-indenticon">&#8627;&#160;</span>
      </xsl:if>
      <a class="ms-searchref-filterlink" href="{$SecureUrl}" title="{$RefineByHeading}: {$UrlTooltip}">
        <xsl:value-of select="Value" />
      </a>
      <xsl:choose>
        <xsl:when test="($ShowCounts = 'Count') and ($Count != '')">
          <span class="ms-searchref-count">
            <xsl:if test="$IsRTL = 'True'">&#x200f;</xsl:if>
            (
            <xsl:value-of select="Count" />
            )
          </span>
        </xsl:when>
        <xsl:when test="($ShowCounts = 'Percentage') and ($Percentage != '')">
          <span class="ms-searchref-count">
            <xsl:if test="$IsRTL = 'True'">&#x200f;</xsl:if>
            (
            <xsl:value-of select="format-number($Percentage, '0%')" />
            )
          </span>
        </xsl:when>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template name="FilterMessage">
    <xsl:param name="Value" />
    <xsl:param name="FilterSelection" />
    <li class="ms-searchref-filtermsg">
      <span class="ms-searchref-filterlink ms-searchref-msg">
        <xsl:value-of select="Value" />
      </span>
    </li>
  </xsl:template>

  <xsl:template name="GetSecureUrl">
    <xsl:param name="Url" />
    <xsl:choose>
      <xsl:when test="$IsDesignMode = 'True'">
        <xsl:value-of select="$Url" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="ddwrt:EnsureAllowedProtocol($Url)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>