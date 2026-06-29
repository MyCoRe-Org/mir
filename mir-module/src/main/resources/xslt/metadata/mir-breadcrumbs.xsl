<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-breadcrumbs.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:variable name="owner">
      <xsl:choose>
        <xsl:when test="mcracl:is-current-user-in-role('admin') or mcracl:is-current-user-in-role('editor')">
          <xsl:text>*</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$CurrentUser" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div id="mir-breadcrumb">
      <ul class="breadcrumb">
        <xsl:if test="$mods/mods:genre[@type='intern']">
          <li class="breadcrumb-item">
            <xsl:call-template name="categorySearchLink">
              <xsl:with-param name="class" select="'navtrail'" />
              <xsl:with-param name="node" select="$mods/mods:genre[@type='intern']"/>
              <xsl:with-param name="parent" select="true()" />
              <xsl:with-param name="owner"  select="$owner" />
            </xsl:call-template>
          </li>
        </xsl:if>
        <li class="breadcrumb-item active">
          <xsl:variable name="completeTitle">
            <xsl:apply-templates select="$mods" mode="mods.title" />
          </xsl:variable>
          <xsl:value-of select="mcrstringutils:shorten($completeTitle,70)" />
        </li>
      </ul>
    </div>
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>