<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" exclude-result-prefixes="mods mcrmods">
  <xsl:import href="xslImport:modsmeta" />
  <xsl:include href="layout-utils.xsl" />
  <xsl:include href="mods-utils.xsl" />
  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right" />
  <xsl:variable name="mods-type">
    <xsl:apply-templates mode="mods-type" select="." />
  </xsl:variable>
  <xsl:template match="/">
    <site>
      <xsl:call-template name="debug-rights" />
      <xsl:choose>
        <xsl:when test="key('rights', mycoreobject/@ID)/@read">
          <xsl:apply-imports />
        </xsl:when>
        <xsl:otherwise>
          <div id="mir-message">
            <xsl:call-template name="printNotLoggedIn" />
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </site>
  </xsl:template>
  <xsl:template name="debug-rights">
    <xsl:variable name="lbr" select="'&#x0a;'" />
    <xsl:comment>
      <xsl:value-of select="concat('Permissions:',$lbr,$lbr)" />
      <xsl:for-each select="/mycoreobject/rights/right">
        <xsl:value-of select="concat(@id,': ')" />
        <xsl:for-each select="@*[not(name()='id')]">
          <xsl:value-of select="concat(' ',name())" />
        </xsl:for-each>
        <xsl:value-of select="$lbr" />
      </xsl:for-each>
    </xsl:comment>
  </xsl:template>

  <xsl:template name="categorySearchLink">
    <xsl:param name="class" />
    <xsl:param name="title" />
    <xsl:param name="node" select="." />
    <xsl:param name="parent" select="false()" />

    <xsl:variable name="classlink">
      <xsl:choose>
        <xsl:when test="$parent=true()">
          <xsl:value-of select="mcrmods:getClassCategParentLink($node)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcrmods:getClassCategLink($node)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($classlink) &gt; 0">
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:message>
            <xsl:value-of select="@ID" />
          </xsl:message>
          <xsl:variable name="classText">
            <xsl:variable name="selectLang">
              <xsl:call-template name="selectLang">
                <xsl:with-param name="nodes" select="./label" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="./label[lang($selectLang)]">
              <xsl:value-of select="@text" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:call-template name="searchLink">
            <xsl:with-param name="class" select="$class" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="linkText" select="$classText" />
            <xsl:with-param name="query" select="concat('%2Bcategory.top%3A&quot;',/mycoreclass/@ID,'%3A',@ID,'&quot;')" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- xsl:message terminate="yes">
          <xsl:value-of select="concat('not a classification: ',name())" />
        </xsl:message -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="searchLink">
    <xsl:param name="class" />
    <xsl:param name="title" />
    <xsl:param name="linkText" />
    <xsl:param name="query" />
    <a href="{$ServletsBaseURL}solr/find?qry={$query}">
      <xsl:if test="$title">
        <xsl:attribute name="title">
          <xsl:value-of select="$title" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$class">
        <xsl:attribute name="class">
          <xsl:value-of select="$class" />
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$linkText" />
    </a>
  </xsl:template>

</xsl:stylesheet>