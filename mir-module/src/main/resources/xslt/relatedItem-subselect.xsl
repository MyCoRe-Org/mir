<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:variable name="xedSession" select="mcrurl:get-param($RequestURL, '_xed_subselect_session')" />

  <xsl:template match="li[a/@class='hit_option hit_edit']">
    <xsl:variable name="objectID" select="substring-after(a/@href, 'id=')" />
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
    <li>
      <a title="" class="hit_option hit_to_basket dropdown-item">
        <xsl:attribute name="href">
          <xsl:value-of select="concat($ServletsBaseURL, 'XEditor?_xed_submit_return= ')" />
          <xsl:value-of select="concat('&amp;_xed_session=', $xedSession)" />
          <xsl:value-of select="concat('&amp;@xlink:href=', $objectID)" />
        </xsl:attribute>
        <span class="fas fa-share-alt" />übernehmen
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
