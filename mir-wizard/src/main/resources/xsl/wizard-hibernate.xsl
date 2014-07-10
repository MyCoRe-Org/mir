<?xml version="1.0" encoding="utf-8"?>
<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" media-type="text/xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"
    doctype-system="http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd" doctype-public="-//Hibernate/Hibernate Configuration DTD 3.0//EN" />

  <xsl:variable name="hibcfg" select="document('resource:hibernate.cfg.xml.template')" />
  <xsl:variable name="dbtypes" select="document('resource:dbtypes.xml')" />

  <xsl:template match="wizard">
    <xsl:apply-templates select="database" />
  </xsl:template>

  <xsl:template match="database">
    <xsl:variable name="dbcfg" select="$dbtypes//db[driver = current()/driver]" />
    <hibernate-configuration>
      <session-factory>
        <property name="connection.driver_class">
          <xsl:value-of select="$dbcfg/driver" />
        </property>
        <property name="connection.url">
          <xsl:value-of select="url" />
        </property>
        <property name="connection.username">
          <xsl:value-of select="username" />
        </property>
        <property name="connection.password">
          <xsl:value-of select="password" />
        </property>
        <property name="dialect">
          <xsl:value-of select="$dbcfg/dialect" />
        </property>
        <xsl:apply-templates select="$hibcfg//property[not(contains('connection.driver_class|connection.url|connection.username|connection.password|dialect', @name))]" />
        <xsl:apply-templates select="$hibcfg//mapping" />
      </session-factory>
    </hibernate-configuration>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>