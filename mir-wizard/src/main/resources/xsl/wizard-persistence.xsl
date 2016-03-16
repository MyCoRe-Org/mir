<?xml version="1.0" encoding="utf-8"?>
<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan">

  <xsl:output method="xml" media-type="text/xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name="xml" select="document('resource:setup/template-persistence.xml')" />
  <xsl:variable name="dbtypes" select="document('resource:setup/dbtypes.xml')" />

  <xsl:variable name="cfg">
    <xsl:copy-of select="/wizard/database" />
    <xsl:copy-of select="$dbtypes//db[driver = /wizard/database/driver]" />
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
        <xsl:when test="name() = 'persistence-unit'">
          <xsl:copy-of select="@*" />
          <xsl:if test="xalan:nodeset($cfg)//extra_properties//property[contains('schema|catalog', @name)]">
            <mapping-file>META-INF/mycore-jpa-defaults.xml</mapping-file>
          </xsl:if>
          <xsl:apply-templates mode="template" />
        </xsl:when>
        <xsl:when test="name() = 'property'">
          <xsl:copy-of select="@*[name() != 'value']" />
          <xsl:attribute name="value">
            <xsl:choose>
              <xsl:when test="@name = 'javax.persistence.jdbc.driver'">
                <xsl:value-of select="xalan:nodeset($cfg)//driver" />
              </xsl:when>
              <xsl:when test="@name = 'javax.persistence.jdbc.url'">
                <xsl:value-of select="xalan:nodeset($cfg)//url" />
              </xsl:when>
              <xsl:when test="@name = 'javax.persistence.jdbc.user'">
                <xsl:value-of select="xalan:nodeset($cfg)//username" />
              </xsl:when>
              <xsl:when test="@name = 'javax.persistence.jdbc.password'">
                <xsl:value-of select="xalan:nodeset($cfg)//password" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@value" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates mode="template" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>