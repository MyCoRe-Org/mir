<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:mirAbstractBadges:badges/xsl-import/mir-abstract-date-badge-xsl-import.xsl" />

  <xsl:include href="resource:xsl/badges/template/date-badge.xsl"/>

  <xsl:template match="/">

    <xsl:apply-imports/>

    <!-- Date badge -->
    <xsl:call-template name="date-badge"/>

  </xsl:template>
</xsl:stylesheet>
