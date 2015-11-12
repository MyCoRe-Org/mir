<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="acl mcrxsl mods"
>
  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />
  <xsl:variable name="addurn" select="'addurn'" />

  <!-- checks for MIRAccessKeyStrategy -->
  <xsl:param name="MCR.Access.Strategy.Class" />
  <xsl:param name="MIR.AccessKeyStrategy.ObjectTypes" />
  <xsl:variable name="derivateAccKeyEnabled" select="contains($MCR.Access.Strategy.Class, 'MIRAccessKeyStrategy') and contains($MIR.AccessKeyStrategy.ObjectTypes, 'derivate')" />
  <xsl:variable name="modsAccKeyEnabled" select="contains($MCR.Access.Strategy.Class, 'MIRAccessKeyStrategy') and contains($MIR.AccessKeyStrategy.ObjectTypes, 'mods')" />

  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:variable name="parentReadable" select="acl:checkPermission(@ID, $read)" />
      <rights>
        <xsl:message>
          Adding rights section
        </xsl:message>
        <xsl:for-each select="@ID|structure/*/*/@xlink:href">
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
      <xsl:choose>
        <xsl:when test="contains($id, '_derivate_')">
          <xsl:if test="mcrxsl:isDisplayedEnabledDerivate($id)">
            <xsl:if test="$parentReadable">
              <xsl:attribute name="view" />
              <xsl:call-template name="check-default-rights">
                <xsl:with-param name="id" select="$id" />
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
          <xsl:if test="$derivateAccKeyEnabled">
            <xsl:call-template name="check-access-keys">
              <xsl:with-param name="id" select="$id" />
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <!-- any mycoreobject here -->
          <xsl:if test="$parentReadable and $id=/mycoreobject/@ID">
            <xsl:attribute name="view" />
          </xsl:if>
          <xsl:call-template name="check-default-rights">
            <xsl:with-param name="id" select="$id" />
          </xsl:call-template>
          <xsl:if test="$modsAccKeyEnabled">
            <xsl:call-template name="check-access-keys">
              <xsl:with-param name="id" select="$id" />
            </xsl:call-template>
          </xsl:if>
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

  <xsl:template name="check-access-keys">
    <xsl:param name="id" />
    <xsl:variable name="accKey" select="document(concat('accesskeys:', $id))/accesskeys" />
    <xsl:message>
      checking for access keys
    </xsl:message>
    <xsl:attribute name="accKeyEnabled" /> <!-- need this to show menu -->
    <xsl:if test="$accKey/@readkey">
      <xsl:attribute name="readKey" />
    </xsl:if>
    <xsl:if test="$accKey/@writekey">
      <xsl:attribute name="writeKey" />
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>