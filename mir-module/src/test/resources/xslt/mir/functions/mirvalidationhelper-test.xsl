<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirvalidationhelper="http://www.mycore.de/xslt/mirvalidationhelper"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="classid" />
  <xsl:param name="categid" />
  <xsl:param name="value" />

  <xsl:template match="/test-classification-exists">
    <result>
      <xsl:value-of select="mirvalidationhelper:classification-exists($classid, $categid)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-validate-sdnb">
    <result>
      <xsl:value-of select="mirvalidationhelper:validateSDNB($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
