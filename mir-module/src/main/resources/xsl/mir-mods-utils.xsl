<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="encoder mcri18n mcrxml mods xalan">

    <xsl:param name="CurrentLang"/>

    <xsl:template match="mods:name" mode="mirNameLink">
        <xsl:variable name="nameIds">
            <xsl:call-template name="getNameIdentifiers">
                <xsl:with-param name="entity" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdentifiers" select="xalan:nodeset($nameIds)/nameIdentifier"/>

        <!-- if user is in role editor or admin, show all; other users only gets their own and published publications -->
        <xsl:variable name="owner">
            <xsl:choose>
                <xsl:when test="mcrxml:isCurrentUserInRole('admin') or mcrxml:isCurrentUserInRole('editor')">
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
        <xsl:if test="count($nameIdentifiers) &gt; 0 or count($affiliations) &gt; 0">
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
        <a href="{concat($ServletsBaseURL,'solr/mods_nameIdentifier?q=',encoder:encode($query),'&amp;owner=',encoder:encode(concat('createdby:',$owner)))}"><xsl:value-of select="$personName" /></a>
        <xsl:if test="count($nameIdentifiers) &gt; 0 or string-length($affiliations) &gt; 0">
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

  <xsl:template match="mods:affiliation[@authority]">
    <xsl:param name="logo-uri" select="''" />
    <xsl:param name="type" select="@authority" />

    <xsl:variable name="logo-uri-val">
      <xsl:choose>
        <xsl:when test="$logo-uri != ''">
          <xsl:value-of select="$logo-uri" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="resolve-affiliation-logo-uri">
            <xsl:with-param name="authority" select="@authority" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="type-val" select="
      translate($type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')
    " />

    <div class="mir-affiliation-{$type-val}">
      <xsl:if test="$logo-uri-val != ''">
        <a href="{@authorityURI}">
          <img src="{$logo-uri-val}" class="pe-1 mir-{$type-val}-logo" alt="{@authority} logo" />
        </a>
      </xsl:if>
      <a class="mir-{$type-val}-link" href="{@valueURI}">
        <xsl:value-of select="@valueURI" />
      </a>
    </div>
  </xsl:template>

  <xsl:template name="resolve-affiliation-logo-uri">
    <xsl:param name="authority" />

    <xsl:choose>
      <xsl:when test="$authority = 'ROR'">
        <xsl:value-of select="concat($WebApplicationBaseURL, 'images/ror/ror-icon-rgb-transparent.svg')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
