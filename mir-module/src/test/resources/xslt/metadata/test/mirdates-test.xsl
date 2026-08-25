<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirdates="http://www.mycore.de/xslt/mirdates"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="resource:xslt/metadata/functions/mirdates.xsl" />

  <xsl:param name="value" />

  <xsl:template match="/test-format">
    <xsl:variable name="date">
      <mods:dateIssued encoding="w3cdtf">
        <xsl:value-of select="$value" />
      </mods:dateIssued>
    </xsl:variable>
    <result>
      <xsl:value-of select="mirdates:format($date/mods:dateIssued)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
