<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:include href="xslInclude:mycoreobjectXML" />

  <xsl:template match="mycoreobject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:if test="mcracl:check-permission(@ID, 'read')">
        <xsl:apply-templates select="node()" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
