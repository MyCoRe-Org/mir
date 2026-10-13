<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

    <xsl:template match="mods:name" mode="mirNameLink">
        <xsl:variable name="nameIds">
            <xsl:call-template name="getNameIdentifiers">
                <xsl:with-param name="entity" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdentifiers" select="$nameIds/nameIdentifier"/>

        <!-- if user is in role editor or admin, show all; other users only gets their own and published publications -->
        <xsl:variable name="owner">
            <xsl:choose>
                <xsl:when test="mcracl:is-current-user-in-role('admin') or mcracl:is-current-user-in-role('editor')">
                    <xsl:text>*</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$CurrentUser"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="query">
            <xsl:choose>
                <xsl:when test="count($nameIdentifiers) &gt; 0">
                    <xsl:for-each select="$nameIdentifiers">
                        <xsl:if test="position()&gt;1">
                            <xsl:text> OR </xsl:text>
                        </xsl:if>
                        <xsl:text>mods.nameIdentifier:</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text>\:</xsl:text>
                        <xsl:value-of select="@id" />
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'+mods.name:&quot;'"/>
                    <xsl:apply-templates select="." mode="queryableNameString"/>
                    <xsl:value-of select="'&quot;'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="affiliations" select="mods:affiliation" />
        <xsl:variable name="personNodeId" select="generate-id(.)"/>
        <xsl:variable name="personName"><xsl:apply-templates select="." mode="nameString"/></xsl:variable>
        <xsl:if test="$nameIdentifiers or $affiliations">
            <!-- This content will be inserted as popover-->
            <div id="{$personNodeId}-content" class="d-none">
                <dl>
                  <xsl:if test="count($nameIdentifiers) &gt; 0">
                    <xsl:for-each select="$nameIdentifiers">
                        <dt>
                            <xsl:value-of select="@label"/>
                        </dt>
                        <dd>
                            <a href="{@uri}{@id}">
                                <xsl:value-of select="@id"/>
                            </a>
                        </dd>
                    </xsl:for-each>
                  </xsl:if>
                  <xsl:apply-templates select="$affiliations">
                    <xsl:sort select="boolean(@authority)" data-type="number" order="ascending" />
                    <xsl:sort select="@valueURI" data-type="text" order="ascending" />
                  </xsl:apply-templates>
                </dl>
            </div>
        </xsl:if>
        <a href="{concat($ServletsBaseURL,'solr/mods_nameIdentifier?q=',encode-for-uri($query),'&amp;owner=',encode-for-uri(concat('createdby:',$owner)))}"><xsl:value-of select="$personName" /></a>
        <xsl:if test="$nameIdentifiers or $affiliations">
            <!-- class personPopover triggers the javascript popover code -->
            <a id="{$personNodeId}" class="personPopover" title="{mcri18n:translate('mir.details.personpopover.title')}">
                <span class="fa fa-info-circle"/>
            </a>
        </xsl:if>
    </xsl:template>

  <xsl:template match="mods:affiliation[not(@*)]">
    <div class="mir-affiliation-plain">
      <xsl:value-of select="." />
    </div>
  </xsl:template>

  <xsl:template match="mods:affiliation[@authority='ROR']">
    <xsl:call-template name="display-affiliation">
      <xsl:with-param name="logo-uri" select="$WebApplicationBaseURL || 'images/ror/ror-icon-rgb-transparent.svg'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:affiliation">
    <xsl:call-template name="display-affiliation" />
  </xsl:template>

  <xsl:template name="display-affiliation">
    <xsl:param name="logo-uri" as="xs:string" select="''" />

    <xsl:variable name="type" select="lower-case(@authority)" />
    <div class="mir-affiliation-{$type}">
      <xsl:if test="$logo-uri != ''">
        <a href="{@authorityURI}">
          <img src="{$logo-uri}" class="pe-1 mir-{$type}-logo" alt="{@authority} logo" />
        </a>
      </xsl:if>
      <a class="mir-{$type}-link" href="{@valueURI}">
        <xsl:value-of select="@valueURI" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
