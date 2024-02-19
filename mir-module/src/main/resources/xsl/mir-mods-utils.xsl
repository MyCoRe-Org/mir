<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:str="http://exslt.org/strings"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:encoder="xalan://java.net.URLEncoder"
                version="1.0"
                exclude-result-prefixes="i18n mcrxml str xalan encoder mods"
>


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

        <xsl:variable name="affiliation" select="mods:affiliation/text()" />
        <xsl:variable name="personNodeId" select="generate-id(.)"/>
        <xsl:variable name="personName"><xsl:apply-templates select="." mode="nameString"/></xsl:variable>
        <xsl:if test="count($nameIdentifiers) &gt; 0 or string-length($affiliation) &gt; 0">
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
                  <xsl:if test="string-length($affiliation) &gt; 0">
                      <dt>
                        <xsl:value-of select="i18n:translate('mir.affiliation')"/>
                      </dt>
                      <dd>
                        <xsl:value-of select="$affiliation"/>
                      </dd>
                  </xsl:if>
                </dl>
            </div>
        </xsl:if>
        <a href="{concat($ServletsBaseURL,'solr/mods_nameIdentifier?q=',encoder:encode($query),'&amp;owner=',encoder:encode(concat('createdby:',$owner)))}"><xsl:value-of select="$personName" /></a>
        <xsl:if test="count($nameIdentifiers) &gt; 0 or string-length($affiliation) &gt; 0">
            <!-- class personPopover triggers the javascript popover code -->
            <a id="{$personNodeId}" class="personPopover" title="{i18n:translate('mir.details.personpopover.title')}">
                <span class="fa fa-info-circle"/>
            </a>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
