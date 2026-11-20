<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/mir/object-page/boxes/derivate-actions/helpers.xsl" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="xslInclude:derivateactions" />

  <xsl:param name="genres" as="xs:string" select="''" />

  <xsl:template match="/">
    <actions>
      <xsl:call-template name="derivate-actions">
        <xsl:with-param name="derivate" select="mycoreobject/structure/derobjects/derobject[1]" />
        <xsl:with-param name="object-id" select="string(mycoreobject/@ID)" />
        <xsl:with-param name="genres" select="tokenize($genres)" />
      </xsl:call-template>
    </actions>
  </xsl:template>

</xsl:stylesheet>
