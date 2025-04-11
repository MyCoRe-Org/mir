<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:mirAbstractBadges:badges/xsl-import/mir-abstract-registered-only-badge-xsl-import.xsl" />

  <xsl:include href="resource:xsl/badges/template/registered-only-badge.xsl"/>

  <xsl:template match="/">

    <xsl:apply-imports/>

    <!-- Registered only badge -->
    <xsl:call-template name="register-only-badge"/>

  </xsl:template>

</xsl:stylesheet>
