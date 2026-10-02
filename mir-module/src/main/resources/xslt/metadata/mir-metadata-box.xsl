<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirboxfields="http://www.mycore.de/xslt/mirboxfields"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/helpers.xsl" />
  <xsl:include href="xslInclude:metadatabox" />

  <xsl:template match="/">
    <xsl:variable name="object" select="mycoreobject" />
    <xsl:variable name="genres" select="mirmods:genres(mirobject:mods($object))" />
    <xsl:variable name="names" select="mirboxfields:get('MIR.MetadataBox.Fields', $genres)" />

    <xsl:if test="exists($names)">
      <div id="mir-metadata">
        <dl>
          <xsl:call-template name="metadata-box-fields">
            <xsl:with-param name="object" select="$object" />
            <xsl:with-param name="genres" select="$genres" />
            <xsl:with-param name="names" select="$names" />
          </xsl:call-template>
        </dl>
      </div>
    </xsl:if>

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
