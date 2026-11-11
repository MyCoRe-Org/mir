<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="*[@authority='gnd'][@valueURI]" mode="value-suffix">
    <a href="{@valueURI}" title="Link zu GND">
      <sup>GND</sup>
    </a>
  </xsl:template>

</xsl:stylesheet>
