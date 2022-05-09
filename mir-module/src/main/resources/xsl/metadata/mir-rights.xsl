<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  exclude-result-prefixes="acl"
>
  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />

  <xsl:include href="coreFunctions.xsl"/>
  
  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:variable name="parentReadable" select="acl:checkPermission(@ID, $read)" />
      <rights>
        <xsl:for-each select="@ID|structure/*/*[not(local-name() = 'child')]/@xlink:href">
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
      <!-- any mycoreobject here -->
      <xsl:if test="$parentReadable and $id=/mycoreobject/@ID">
        <xsl:attribute name="view" />
      </xsl:if>
      <xsl:call-template name="check-default-rights">
        <xsl:with-param name="id" select="$id" />
      </xsl:call-template>
    </right>
  </xsl:template>

  <xsl:template name="check-default-rights">
    <xsl:param name="id" />
    <xsl:if test="acl:checkPermission($id,$read)">
      <xsl:attribute name="read" />
      <xsl:if test="acl:checkPermission($id,$write)">
        <xsl:attribute name="write" />
        <xsl:if test="acl:checkPermission($id,$delete)">
          <xsl:attribute name="delete" />
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
