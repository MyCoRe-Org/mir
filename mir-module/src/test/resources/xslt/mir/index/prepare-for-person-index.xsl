<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="value" as="xs:string" />

  <xsl:template match="/">
    <result>
      <prepared>
        <xsl:value-of select="string(document(concat('prepareForPersonIndex:',encode-for-uri($value))))"/>
      </prepared>
    </result>
  </xsl:template>

</xsl:stylesheet>
