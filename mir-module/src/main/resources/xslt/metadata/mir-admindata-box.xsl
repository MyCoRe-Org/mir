<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirboxfields="http://www.mycore.de/xslt/mirboxfields"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-admindata-box.xsl" />
  <xsl:import href="resource:xslt/metadata/admindata-box/helpers.xsl" />
  <xsl:include href="xslInclude:admindatabox" />

  <xsl:template match="/">
    <div id="mir-admindata">
      <dl>
        <xsl:call-template name="admindata-box-fields">
          <xsl:with-param name="object" select="mycoreobject" />
          <xsl:with-param name="names" select="mirboxfields:get('MIR.AdmindataBox.Fields', ())" />
        </xsl:call-template>
      </dl>
    </div>

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
