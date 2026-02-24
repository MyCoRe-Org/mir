<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="local:local"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="local xs">

  <xsl:output method="text" />

  <xsl:param name="dir" as="xs:string" select="'src/main/resources/xsl'" />

  <xsl:template name="main">
    <xsl:variable name="all-files" select="
      collection(
        concat(
          $dir,
          '?select=*.xsl;recurse=yes;unparsed=yes;on-error=ignore'
        )
      )
    " />
    <xsl:for-each select="$all-files">
      <xsl:variable name="file" select="base-uri(.)" />
      <xsl:variable name="content" select="unparsed-text($file)" />
      <xsl:variable name="doc" select="doc($file)" />

      <xsl:apply-templates select="$doc" mode="validate">
        <xsl:with-param name="file" select="$file" />
        <xsl:with-param name="content" select="$content" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xsl:stylesheet | xsl:transform" mode="validate">
    <xsl:param name="file" />
    <xsl:param name="content" />

    <xsl:variable name="encoding" select="local:extract-encoding($content)" />
    <xsl:if test="not($encoding = 'UTF-8')">
      <xsl:message terminate="yes">
        ERROR in <xsl:value-of select="$file" />: Encoding is '<xsl:value-of select="$encoding" />', but it must be
        UTF-8.
      </xsl:message>
    </xsl:if>
    <xsl:variable name="ns-declarations" select="local:extract-ns-declarations($content)" />
    <xsl:variable name="sorted" select="sort($ns-declarations)" />
    <xsl:if test="not(deep-equal($ns-declarations, $sorted))">
      <xsl:message terminate="yes">
        ERROR in <xsl:value-of select="$file" />: Namespace declarations are not sorted alphabetically. Actual:
        <xsl:value-of select="$ns-declarations" separator="&#10;" /> Expected:
        <xsl:value-of select="$sorted" separator="&#10;" />
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:function name="local:extract-encoding" as="xs:string">
    <xsl:param name="content" as="xs:string" />
    <xsl:variable name="result" as="xs:string*">
      <xsl:analyze-string select="$content" regex="encoding=[&quot;&apos;]([^&quot;&apos;]+)[&quot;&apos;]">
        <xsl:matching-substring>
          <xsl:sequence select="regex-group(1)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="($result[1], '')[1]" />
  </xsl:function>

  <xsl:function name="local:extract-ns-declarations" as="xs:string*">
    <xsl:param name="content" as="xs:string" />
    <xsl:variable name="stylesheet-start-tag" as="xs:string">
      <xsl:analyze-string select="$content" regex="&lt;xsl:stylesheet[^&gt;]*&gt;">
        <xsl:matching-substring>
          <xsl:sequence select="." />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:variable name="ns-declarations" as="xs:string*">
      <xsl:analyze-string select="$stylesheet-start-tag" regex="xmlns:[a-zA-Z0-9_]+=&quot;[^&quot;]*&quot;">
        <xsl:matching-substring>
          <xsl:sequence select="." />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="$ns-declarations" />
  </xsl:function>

</xsl:stylesheet>
