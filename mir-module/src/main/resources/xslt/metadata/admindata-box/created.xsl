<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='created']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="service-date-row">
      <xsl:with-param name="date" select="$object/service/servdates/servdate[@type='createdate'][1]" />
      <xsl:with-param name="label-key" select="'metaData.createdAt'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='created.by']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="user-info-row">
      <xsl:with-param name="userid" select="$object/service/servflags/servflag[@type='createdby'][1]" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
