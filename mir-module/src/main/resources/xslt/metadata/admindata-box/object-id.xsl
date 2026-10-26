<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='object-id']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="meta-row">
      <xsl:with-param name="label-key" select="'metaData.ID'" />
      <xsl:with-param name="value" select="string($object/@ID)" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
