<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='modified']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="service-date-row">
      <xsl:with-param name="date" select="$object/service/servdates/servdate[@type='modifydate'][1]" />
      <xsl:with-param name="label-key" select="'metaData.lastChanged'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='modified.by']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="user-info-row">
      <xsl:with-param name="userid" select="$object/service/servflags/servflag[@type='modifiedby'][1]" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
