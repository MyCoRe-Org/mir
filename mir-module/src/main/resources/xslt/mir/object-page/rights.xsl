<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />

  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@* | node()" />
      <xsl:variable name="parentReadable" select="mcracl:check-permission(@ID, $read)" />
      <rights>
        <xsl:for-each select="@ID | structure/*/*[not(local-name() = 'child')]/@xlink:href">
          <xsl:call-template name="check-rights">
            <xsl:with-param name="id" select="." />
            <xsl:with-param name="parentReadable" select="$parentReadable" />
          </xsl:call-template>
        </xsl:for-each>
      </rights>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="check-rights">
    <xsl:param name="id" />
    <xsl:param name="parentReadable" select="false()" />
    <right id="{$id}">
      <xsl:if test="$parentReadable and $id = string(/mycoreobject/@ID)">
        <xsl:attribute name="view" />
      </xsl:if>
      <xsl:call-template name="check-default-rights">
        <xsl:with-param name="id" select="$id" />
      </xsl:call-template>
    </right>
  </xsl:template>

  <xsl:template name="check-default-rights">
    <xsl:param name="id" />
    <xsl:if test="mcracl:check-permission($id, $read)">
      <xsl:attribute name="read" />
      <xsl:if test="mcracl:check-permission($id, $write)">
        <xsl:attribute name="write" />
        <xsl:if test="mcracl:check-permission($id, $delete)">
          <xsl:attribute name="delete" />
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
