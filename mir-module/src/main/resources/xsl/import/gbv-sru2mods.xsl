<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:srw="http://www.loc.gov/zing/srw/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="srw xsl">

  <xsl:template match="/srw:searchRetrieveResponse">
    <xsl:copy-of select="srw:records/srw:record[1]/srw:recordData/mods:mods" />
  </xsl:template>  

</xsl:stylesheet>
