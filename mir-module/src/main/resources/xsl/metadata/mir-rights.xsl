<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="acl mcrxsl mods">
  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />
  <xsl:variable name="addurn" select="'addurn'" />
  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:variable name="view-derivate" select="acl:checkPermission(@ID,'view-derivate')" />
      <rights>
        <xsl:message>
          Adding rights section
        </xsl:message>
        <xsl:for-each select="@ID|structure/*/*/@xlink:href">
          <xsl:call-template name="check-rights">
            <xsl:with-param name="id" select="." />
            <xsl:with-param name="view-derivate" select="$view-derivate" />
          </xsl:call-template>
        </xsl:for-each>
      </rights>
    </xsl:copy>
  </xsl:template>
  <xsl:template name="check-rights">
    <xsl:param name="id" />
    <xsl:param name="view-derivate" select="false()" />
    <right id="{$id}">
      <xsl:choose>
        <xsl:when test="contains($id, '_derivate_')">
          <xsl:if test="mcrxsl:isDisplayedEnabledDerivate($id)">
            <xsl:if test="$view-derivate">
              <xsl:attribute name="view" />
              <xsl:call-template name="check-default-rights">
                <xsl:with-param name="id" select="$id" />
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <!-- any mycoreobject here -->
          <xsl:if test="$view-derivate and $id=/mycoreobject/@ID">
            <xsl:attribute name="view" />
          </xsl:if>
          <xsl:call-template name="check-default-rights">
            <xsl:with-param name="id" select="$id" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </right>
  </xsl:template>

  <xsl:template name="check-default-rights">
    <xsl:param name="id" />
    <xsl:message>
      checking read permission
    </xsl:message>
    <xsl:if test="acl:checkPermission($id,$read)">
      <xsl:attribute name="read" />
      <xsl:message>
        checking write permission
      </xsl:message>
      <xsl:if test="acl:checkPermission($id,$write)">
        <xsl:attribute name="write" />
        <xsl:if test="acl:checkPermission($id,$addurn)">
          <xsl:attribute name="addurn" />
        </xsl:if>
        <xsl:if test="acl:checkPermission($id,$delete)">
          <xsl:attribute name="delete" />
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>