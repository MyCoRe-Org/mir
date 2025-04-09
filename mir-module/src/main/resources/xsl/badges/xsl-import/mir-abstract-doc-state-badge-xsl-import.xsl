<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:mirAbstractBadges:badges/xsl-import/mir-abstract-doc-state-badge-xsl-import.xsl" />

  <xsl:include href="resource:xsl/badges/template/doc-state-badge.xsl"/>

  <xsl:template match="/">
    <xsl:apply-imports/>

    <!-- Doc state badge -->
    <xsl:call-template name="doc-state-badge"/>

  </xsl:template>

</xsl:stylesheet>
