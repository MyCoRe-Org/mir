<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="acl mcrxsl mods"
  xmlns:ex="http://exslt.org/dates-and-times" extension-element-prefixes="ex"
>
  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />
  <xsl:variable name="addurn" select="'addurn'" />

  <!-- checks for MIRAccessKeyStrategy -->
  <xsl:variable name="derivateAccKeyEnabled" select="false()" />
  <xsl:variable name="modsAccKeyEnabled" select="true()" />

  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:variable name="parentReadable" select="acl:checkPermission(@ID, $read)" />
      <rights>
        <xsl:message>
          Adding rights section
        </xsl:message>
        <xsl:variable name="embargo" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
        <xsl:variable name="isEmbargo">
          <xsl:choose>
            <xsl:when test="mcrxsl:isCurrentUserGuestUser() and count($embargo) &gt; 0 and mcrxsl:compare(string($embargo),ex:date-time()) &gt; 0">
              <xsl:value-of select="'true'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:for-each select="@ID|structure/*/*/@xlink:href">
          <xsl:call-template name="check-rights">
            <xsl:with-param name="id" select="." />
            <xsl:with-param name="parentReadable" select="$parentReadable" />
            <xsl:with-param name="embargo" select="$isEmbargo" />
          </xsl:call-template>
        </xsl:for-each>
      </rights>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="check-rights">
    <xsl:param name="id" />
    <xsl:param name="parentReadable" select="false()" />
    <xsl:param name="embargo" select="'false'" />
    <right id="{$id}">
      <xsl:choose>
        <xsl:when test="contains($id, '_derivate_') and $embargo='false'">
          <xsl:if test="mcrxsl:isDisplayedEnabledDerivate($id)">
            <xsl:if test="$parentReadable">
              <xsl:attribute name="view" />
              <xsl:call-template name="check-default-rights">
                <xsl:with-param name="id" select="$id" />
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
          <xsl:if test="not(mcrxsl:isDisplayedEnabledDerivate($id)) and acl:checkPermission($id,$write)">
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
        <xsl:when test="contains($id, '_derivate_') and $embargo='true'">
          <xsl:attribute name="embargo" />
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