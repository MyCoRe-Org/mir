<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exslt="http://exslt.org/common"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exslt mcri18n mods">

  <xsl:import href="xslImport:modsmeta:metadata/mir-export.xsl" />
  <xsl:param name="MCR.Export.Transformers" />
  <xsl:template match="/">
    <xsl:variable name="objectId" select="/mycoreobject/@ID" />
    <xsl:variable name="transformerTokens">
      <xsl:call-template name="Tokenizer">
        <xsl:with-param name="string" select="$MCR.Export.Transformers" />
        <xsl:with-param name="delimiter" select="','" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="transformers" select="exslt:node-set($transformerTokens)/token" />
    <xsl:if test="$transformers">
      <div id="mir-export">
        <xsl:call-template name="exportTransformer">
          <xsl:with-param name="transformer" select="$transformers[1]" />
          <xsl:with-param name="objectId" select="$objectId" />
        </xsl:call-template>
        <xsl:for-each select="$transformers[position()>1]">
          <xsl:call-template name="printSeparator" />
          <xsl:call-template name="exportTransformer">
            <xsl:with-param name="transformer" select="." />
            <xsl:with-param name="objectId" select="$objectId" />
          </xsl:call-template>
        </xsl:for-each>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>
  <xsl:template name="exportTransformer">
    <xsl:param name="transformer" />
    <xsl:param name="objectId"  />
    <xsl:call-template name="exportLink">
      <xsl:with-param name="transformer" select="substring-before($transformer,':')" />
      <xsl:with-param name="linkText" select="substring-after($transformer,':')" />
      <xsl:with-param name="objectId" select="$objectId" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="exportLink">
    <xsl:param name="transformer" />
    <xsl:param name="linkText" />
    <xsl:param name="objectId"  />
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',$objectId,'?XSL.Transformer=',$transformer)" />
      </xsl:attribute>
      <xsl:value-of select="$linkText" />
    </a>
  </xsl:template>
  <xsl:template name="printSeparator">
    <span><xsl:text>, </xsl:text></span>
  </xsl:template>
</xsl:stylesheet>
