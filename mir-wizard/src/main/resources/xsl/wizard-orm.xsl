<?xml version="1.0" encoding="utf-8"?>
<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan">

  <xsl:output method="xml" media-type="text/xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name="xml" select="document('resource:setup/template-orm.xml')" />

  <xsl:variable name="cfg">
    <xsl:copy-of select="/wizard/database" />
  </xsl:variable>

  <xsl:template match="wizard">
    <xsl:apply-templates select="database" />
  </xsl:template>

  <xsl:template match="database">
    <xsl:apply-templates select="$xml" mode="template" />
  </xsl:template>

  <xsl:template match="*" mode="template">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="name() = 'persistence-unit-defaults'">
          <xsl:if test="xalan:nodeset($cfg)//extra_properties//property[contains('schema|catalog', @name)]">
            <xsl:for-each select="xalan:nodeset($cfg)//extra_properties//property[contains('schema|catalog', @name)]">
              <xsl:element name="{@name}">
                <xsl:value-of select="." />
              </xsl:element>
            </xsl:for-each>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates mode="template" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>