<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:include href="modsmetadata.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-metadata">
      <xsl:apply-templates />
      <!--
      <dl>
        <dt>metaname</dt>
        <dd>metavalue</dd>
      </dl> 
       -->

      <xsl:choose>
        <xsl:when test="$mods-type='series'">
          <xsl:apply-templates select="." mode="objectActions">
            <xsl:with-param name="layout" select="'journal'" />
            <xsl:with-param name="mods-type" select="$mods-type" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="objectActions">
            <xsl:with-param select="$mods-type" name="layout" />
            <xsl:with-param select="$mods-type" name="mods-type" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <!-- xsl:when cases are handled in modsmetadata.xsl -->
        <xsl:when test="$mods-type = 'report'">
          <xsl:apply-templates select="." mode="present.report" />
        </xsl:when>
        <xsl:when test="$mods-type = 'thesis'">
          <xsl:apply-templates select="." mode="present.thesis" />
        </xsl:when>
        <xsl:when test="$mods-type = 'confpro'">
          <xsl:apply-templates select="." mode="present.confpro" />
        </xsl:when>
        <xsl:when test="$mods-type = 'confpub'">
          <xsl:apply-templates select="." mode="present.confpub" />
        </xsl:when>
        <xsl:when test="$mods-type = 'book'">
          <xsl:apply-templates select="." mode="present.book" />
        </xsl:when>
        <xsl:when test="$mods-type = 'chapter'">
          <xsl:apply-templates select="." mode="present.chapter" />
        </xsl:when>
        <xsl:when test="$mods-type = 'journal'">
          <xsl:apply-templates select="." mode="present.journal" />
        </xsl:when>
        <xsl:when test="$mods-type = 'series'">
          <xsl:apply-templates select="." mode="present.series" />
        </xsl:when>
        <xsl:when test="$mods-type = 'article'">
          <xsl:apply-templates select="." mode="present.article" />
        </xsl:when>
        <xsl:when test="$mods-type = 'av'">
          <xsl:apply-templates select="." mode="present.av" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="present.modsDefaultType">
            <xsl:with-param name="mods-type" select="$mods-type" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>