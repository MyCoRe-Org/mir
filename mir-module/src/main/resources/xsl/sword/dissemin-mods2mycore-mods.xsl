<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mets="http://www.loc.gov/METS/" xmlns:ds="https://dissem.in/deposit/terms/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:xml="http://www.w3.org/XML/1998/namespace"
                xmlns:langDetect="xalan://org.mycore.common.MCRLanguageDetector"
                version="1.0"
                exclude-result-prefixes="mods xalan langDetect ds mets">

  <xsl:template match='@*|node()'>
    <xsl:param name="ID" />
    <!-- default template: just copy -->
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
      <xsl:if test="$ID">
        <xsl:attribute name="ID">
          <xsl:value-of select="$ID" />
        </xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/mets:mets">
    <xsl:apply-templates select="mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods"/>
  </xsl:template>

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:attribute name="version">3.7</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <xsl:copy>
      <xsl:attribute name="type" namespace="http://www.w3.org/1999/xlink">simple</xsl:attribute>
      <!-- Try to detect the language with the MCRLanguageDetector -->
      <xsl:if test="count(mods:title)&gt;0">
        <xsl:variable name="detected" select="langDetect:detectLanguage(mods:title/text())"/>
        <xsl:if test="string-length($detected)&gt;0">
          <xsl:attribute name="lang" namespace="http://www.w3.org/XML/1998/namespace">
            <xsl:value-of select="$detected"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:relatedItem">
    <xsl:copy>
      <xsl:attribute name="type">host</xsl:attribute>
      <!-- guess the genre if not present -->
      <xsl:if test="not(mods:genre)">
        <xsl:variable name="parentGenre">
          <xsl:choose>
            <xsl:when test="../mods:genre/text()='book-chapter'">book</xsl:when>
            <xsl:when test="../mods:genre/text()='journal-article'">journal</xsl:when>
            <xsl:when test="../mods:genre/text()='journal-issue'">journal</xsl:when>
            <xsl:when test="../mods:genre/text()='proceedings-article'">proceedings</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($parentGenre)&gt;0">
          <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres"
                      valueURI="http://www.mycore.org/classifications/mir_genres#{$parentGenre}"/>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates/>
    </xsl:copy>

  </xsl:template>


  <xsl:template match="mods:genre">
    <xsl:variable name="genre">
      <xsl:choose>
        <xsl:when test="text()='book'">book</xsl:when>
        <xsl:when test="text()='book-chapter'">chapter</xsl:when>
        <xsl:when test="text()='journal-article'">article</xsl:when>
        <xsl:when test="text()='journal-issue'">issue</xsl:when>
        <xsl:when test="text()='poster'">poser</xsl:when>
        <xsl:when test="text()='proceedings'">proceedings</xsl:when>
        <xsl:when test="text()='report'">report</xsl:when>
        <xsl:when test="text()='thesis'">thesis</xsl:when>
        <xsl:when test="text()='proceedings-article'">article</xsl:when>
        <xsl:when test="text()='preprint'">article</xsl:when>
        <!--<xsl:when test="text()='other'"></xsl:when>-->
        <!--<xsl:when test="text()='dataset'"></xsl:when>-->
        <!--<xsl:when test="text()='reference-entry'"></xsl:when>-->
        <xsl:otherwise><xsl:message terminate="yes">Could not detect the right genre for <xsl:value-of select="text()" /></xsl:message> </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($genre) &gt; 0">
      <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres"
                  valueURI="http://www.mycore.org/classifications/mir_genres#{$genre}"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>