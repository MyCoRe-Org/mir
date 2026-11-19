<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/mir/object-page/boxes/metadata/shared/classification-link.xsl" />

  <xsl:param name="MCR.Module-iview2.SupportedContentTypes" />
  <xsl:param name="MIR.Thumbnail.IIIF.Resolution" select="'!300,300'" />

  <xsl:include href="resource:xslt/mir/mods/utils.xsl" />
  <xsl:include href="resource:xslt/mir/utils/common.xsl" />
  <xsl:include href="resource:xslt/mir/layout/utils.xsl" />

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]" mode="basketContent" priority="1">
    <xsl:variable name="object" select="." />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:call-template name="basket-hit-preview">
        <xsl:with-param name="object" select="$object" />
      </xsl:call-template>
      <xsl:call-template name="basket-hit-badges">
        <xsl:with-param name="object-id" select="string($object/@ID)" />
      </xsl:call-template>
      <h3 class="hit_title">
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="$object/@ID" />
        </xsl:call-template>
      </h3>
      <xsl:call-template name="basket-hit-authors">
        <xsl:with-param name="mods" select="." />
      </xsl:call-template>
      <xsl:call-template name="basket-hit-parent">
        <xsl:with-param name="object" select="$object" />
      </xsl:call-template>
      <xsl:call-template name="basket-hit-abstract">
        <xsl:with-param name="mods" select="." />
      </xsl:call-template>
      <xsl:call-template name="basket-hit-publishers">
        <xsl:with-param name="mods" select="." />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="basket-hit-preview">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:variable name="derivate-id" select="string($object/structure/derobjects/derobject[1]/@xlink:href)" />
    <div class="hit_download_box">
      <xsl:choose>
        <xsl:when test="$derivate-id != ''">
          <xsl:variable name="derivate" select="document(concat('mcrobject:', $derivate-id))" />
          <xsl:variable name="main-doc" select="string($derivate/mycorederivate/derivate/internals/internal/@maindoc)" />
          <xsl:variable name="content-type" select="
            string(document(concat('ifs:/', $derivate-id))/mcr_directory/children/child[name = $main-doc][1]/contentType)
          " />
          <xsl:variable name="supported-content-types" select="
            tokenize($MCR.Module-iview2.SupportedContentTypes, ',') ! normalize-space()
          " />
          <xsl:choose>
            <xsl:when test="$content-type != '' and ($content-type = $supported-content-types or $content-type = 'application/pdf')">
              <xsl:variable name="icon-src" select="
                concat($WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $object/@ID, '/full/', $MIR.Thumbnail.IIIF.Resolution, '/0/default.jpg')
              " />
              <div class="hit_icon">
                <xsl:choose>
                  <xsl:when test="mcracl:is-current-user-guest-user()">
                    <img alt="" src="{$icon-src}" />
                  </xsl:when>
                  <xsl:otherwise>
                    <img alt="" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" data-iiif-jwt="{$icon-src}" />
                  </xsl:otherwise>
                </xsl:choose>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="hit_icon">
                <img alt="" src="{$WebApplicationBaseURL}images/icons/icon_common.png" />
              </div>
              <xsl:variable name="icon-link">
                <xsl:call-template name="iconLink">
                  <xsl:with-param name="baseURL" select="$WebApplicationBaseURL" />
                  <xsl:with-param name="mimeType" select="$content-type" />
                  <xsl:with-param name="derivateMaindoc" select="$main-doc" />
                </xsl:call-template>
              </xsl:variable>
              <img alt="{mcrderivate:get-file-extension($main-doc)}" class="hit_icon_overlay" src="{$icon-link}" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <img alt="" class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="basket-hit-badges">
    <xsl:param name="object-id" as="xs:string" />

    <div class="hit_tnd_container">
      <div class="hit_tnd_content mir-badge-container">
        <xsl:apply-templates select="document(concat('solr:q=id%3A', $object-id))/response/result/doc" mode="badge" />
      </div>
    </div>
  </xsl:template>

  <xsl:template name="basket-hit-authors">
    <xsl:param name="mods" as="element(mods:mods)" />

    <div class="hit_author">
      <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm/text() = 'aut']">
        <xsl:if test="position() != 1">
          <xsl:value-of select="'/ '" />
        </xsl:if>
        <xsl:apply-templates select="." mode="mirNameLink" />
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="basket-hit-parent">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:variable name="parent-id" select="$object/structure/parents/parent/@xlink:href" />
    <xsl:if test="$parent-id">
      <div class="hit_source">
        <span class="label_parent">
          <xsl:value-of select="'aus: '" />
        </span>
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="$parent-id" />
        </xsl:call-template>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="basket-hit-abstract">
    <xsl:param name="mods" as="element(mods:mods)" />

    <xsl:variable name="abstracts" select="$mods/mods:abstract[not(@altFormat)]" />
    <div class="hit_abstract">
      <xsl:if test="exists($abstracts)">
        <xsl:value-of select="mcrstringutils:shorten(($abstracts[@xml:lang = $CurrentLang], $abstracts)[1], 300)" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="basket-hit-publishers">
    <xsl:param name="mods" as="element(mods:mods)" />

    <xsl:variable name="publication-publisher" select="$mods/mods:originInfo[not(@eventType) or @eventType = 'publication']/mods:publisher" />
    <xsl:if test="$publication-publisher">
      <div class="hit_pub_name">
        <span class="label_publisher">
          <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.published'), ': ')" />
        </span>
        <xsl:value-of select="$publication-publisher" />
      </div>
    </xsl:if>
    <xsl:variable name="creation-publisher" select="$mods/mods:originInfo[@eventType = 'creation']/mods:publisher" />
    <xsl:if test="$creation-publisher">
      <div class="hit_pub_name">
        <span class="label_publisher">
          <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.publisher.creation'), ': ')" />
        </span>
        <xsl:value-of select="$creation-publisher" />
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
