<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcracl">

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="resource:xsl/copynodes.xsl" />
  <xsl:include href="xslInclude:mycoreobjectXML" />

  <xsl:template match="mycoreobject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	<!-- check the READ permission -->
      <xsl:if test="mcracl:checkPermission(@ID,'read')">
        <xsl:apply-templates select="node()" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
