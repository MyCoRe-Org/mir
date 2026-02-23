<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="encoder xalan xsl">

  <xsl:include href="coreFunctions.xsl" />
  <xsl:include href="copynodes.xsl" />
  <xsl:param name="RequestURL" />

  <!-- ========== XED Subselect detection ========== -->
  <xsl:variable name="xedSession">
    <xsl:call-template name="UrlGetParam">
      <xsl:with-param name="url" select="$RequestURL" />
      <xsl:with-param name="par" select="'_xed_subselect_session'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="li[a/@class='hit_option hit_edit']">
    <xsl:variable name="objectID" select="substring-after(a/@href, 'id=')" />
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
    <li>
      <a title="" class="hit_option hit_to_basket dropdown-item">
        <xsl:attribute name="href">
          <xsl:value-of select="concat($ServletsBaseURL,'XEditor?_xed_submit_return= ')" />
          <xsl:value-of select="concat('&amp;_xed_session=',encoder:encode($xedSession,'UTF-8'))" />
          <xsl:value-of select="concat('&amp;@xlink:href=',encoder:encode($objectID,'UTF-8'))" />
        </xsl:attribute>
        <span class="fas fa-share-alt"/>übernehmen
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>