<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirboxfields="http://www.mycore.de/xslt/mirboxfields"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:mir/object/boxes/mir-admindata-box.xsl" />
  <xsl:import href="resource:xslt/metadata/admindata-box/helpers.xsl" />
  <xsl:include href="xslInclude:admindatabox" />

  <xsl:template match="/">
    <xsl:variable name="names" select="mirboxfields:get('MIR.AdmindataBox.Fields', ())" />

    <xsl:if test="exists($names)">
      <div id="mir-admindata">
        <dl>
          <xsl:call-template name="admindata-box-fields">
            <xsl:with-param name="object" select="mycoreobject" />
            <xsl:with-param name="names" select="$names" />
          </xsl:call-template>
        </dl>
      </div>
    </xsl:if>

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
