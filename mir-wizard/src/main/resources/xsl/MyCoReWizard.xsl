<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>

<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xlink xalan i18n">
  &html-output;
  
  <xsl:include href="MyCoReLayout.xsl" />

  <xsl:variable name="PageTitle">
    <xsl:choose>
      <xsl:when test="/MyCoReWizard/section/@i18n">
        <xsl:value-of select="i18n:translate(/MyCoReWizard/section/@i18n)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="/MyCoReWizard/section[ lang($CurrentLang)]/@title != '' ">
            <xsl:value-of select="/MyCoReWizard/section[lang($CurrentLang)]/@title" />
          </xsl:when>
          <xsl:when test="/MyCoReWizard/section[@alt and contains(@alt,$CurrentLang)]/@title != '' ">
            <xsl:value-of select="/MyCoReWizard/section[contains(@alt,$CurrentLang)]/@title" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/MyCoReWizard/section[lang($DefaultLang)]/@title" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="Servlet" select="'undefined'" />

  <!-- =============================================================================== -->

  <xsl:template match="/MyCoReWizard">
    <xsl:choose>
      <xsl:when test="section[@direction = $direction]">
        <xsl:apply-templates select="section[@direction = $direction]" />
      </xsl:when>
      <xsl:when test="section[lang($CurrentLang)]">
        <xsl:apply-templates select="section[lang($CurrentLang) or lang('all') or contains(@alt,$CurrentLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="section[lang($DefaultLang) or lang('all') or contains(@alt,$DefaultLang)]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- =============================================================================== -->

  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>

  <!-- =============================================================================== -->

  <xsl:template match="section">
    <xsl:for-each select="node()">
      <xsl:apply-templates select="." />
    </xsl:for-each>
  </xsl:template>

  <!-- =============================================================================== -->

  <xsl:template match="i18n">
    <xsl:value-of select="i18n:translate(@key)" />
  </xsl:template>

  <!-- =============================================================================== -->

</xsl:stylesheet>