<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" >

  <xsl:include href="utils/mods-utils.xsl" />
  <xsl:include href="mods2html.xsl" />
  <xsl:include href="modsmetadata.xsl" />

  <xsl:include href="resource:xslt/basket.xsl" />

  <xsl:include href="modshitlist-external.xsl" />  <!-- for external usage in application module -->
  <xsl:include href="modsdetails-external.xsl" />  <!-- for external usage in application module -->

  <!--Template for title in metadata view: see mycoreobject.xsl -->
  <xsl:template priority="1" mode="title" match="/mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="mods-type">
      <xsl:apply-templates select="." mode="mods-type" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mods-type='confpro'">
        <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods" mode="mods.title.confpro" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title">
                  <!-- TODO: if editor bug fixed -->
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[1]" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$text" disable-output-escaping="yes" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@ID" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="doc-available('resource:actionmappings.xml')">
        <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="mcractionmapping:get-url-for-collection('update-xml',$collection,true())"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mcractionmapping:get-url-for-collection('update',$collection,true())"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="mcractionmapping:get-url-for-id('update-xml',$id,true())"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mcractionmapping:get-url-for-id('update',$id,true())"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:value-of select="mcrurl:set-param($url,'id',$id)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:variable name="layoutSuffix">
          <xsl:if test="$layout != '$'">
            <xsl:value-of select="concat('-',$layout)" />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="form" select="concat('editor_form_commit-mods',$layoutSuffix,'.xml')" />
        <xsl:value-of select="concat($WebApplicationBaseURL,$form,'?id=',$id)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
