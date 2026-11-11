<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/mir/object-page/boxes/metadata/shared/classification-link.xsl" />

  <xsl:param name="MCR.Module-iview2.SupportedContentTypes" />
  <xsl:param name="MIR.Thumbnail.IIIF.Resolution" select="'!300,300'" />

  <xsl:include href="resource:xslt/mir/mods/utils.xsl" />
  <xsl:include href="resource:xslt/mir/utils/common.xsl" />
  <xsl:include href="resource:xslt/mir/layout/utils.xsl" />

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]" mode="basketContent" priority="1">
    <xsl:variable name="objID" select="@ID" />

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods">

<!-- document preview -->
      <div class="hit_download_box">
        <xsl:choose>
        <!-- we got a derivate -->
        <xsl:when test="../../../../structure/derobjects">
          <xsl:variable name="identifier" select="../../../../@ID" />
          <xsl:variable name="derivid" select="../../../../structure/derobjects/derobject[1]/@xlink:href" />
          <xsl:variable name="derivate" select="document(concat('mcrobject:',$derivid))" />
          <xsl:variable name="maindoc" select="$derivate/mycorederivate/derivate/internals/internal/@maindoc" />
          <xsl:variable name="contentType" select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType" />

          <xsl:choose>
            <xsl:when test="contains($MCR.Module-iview2.SupportedContentTypes, $contentType) or $contentType ='application/pdf'">
              <div class="hit_icon">
                <xsl:variable name="title">
                  <xsl:apply-templates select="ancestor::mycoreobject" mode="resulttitle" />
                </xsl:variable>
                <img alt="{mcri18n:translate('metaData.preview')}: {normalize-space($title)}">
                  <xsl:variable name="hitIconSrc" select="concat($WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $identifier, '/full/', $MIR.Thumbnail.IIIF.Resolution, '/0/default.jpg')"/>
                  <xsl:choose>
                    <xsl:when test="not(mcracl:is-current-user-guest-user())">
                      <xsl:attribute name="src">
                        <xsl:value-of select="concat($WebApplicationBaseURL, 'images/icons/icon_common_disabled.png')"/>
                      </xsl:attribute>
                      <xsl:attribute name="data-iiif-jwt">
                        <xsl:value-of select="$hitIconSrc"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="src">
                        <xsl:value-of select="$hitIconSrc"/>
                      </xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
                </img>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="hit_icon">
                <img alt="" src="{$WebApplicationBaseURL}images/icons/icon_common.png"/>
              </div>
              <!-- if not, then the content type decides a icon -->
              <xsl:variable name="iconLink">
                <xsl:call-template name="iconLink">
                  <xsl:with-param name="baseURL" select="$WebApplicationBaseURL"/>
                  <xsl:with-param name="mimeType" select="$contentType"/>
                </xsl:call-template>
              </xsl:variable>
              <img alt="{mcrderivate:get-file-extension($maindoc)}" class="hit_icon_overlay" src="{$iconLink}"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
          <!-- no derivate -->
          <xsl:otherwise>
            <!-- show default icon -->
            <img alt="" class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
          </xsl:otherwise>
        </xsl:choose>
      </div>

<!-- hit type -->
      <div class="hit_tnd_container">
        <div class="hit_tnd_content mir-badge-container">
          <xsl:apply-templates select="document(concat('solr:q=id%3A', $objID))/response/result/doc" mode="badge"/>
        </div>
      </div>

      <!-- Title, Link to presentation -->
      <h3 class="hit_title">
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="$objID" />
        </xsl:call-template>
      </h3>

<!-- hit author -->
      <div class="hit_author">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'/ '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="mirNameLink" />
        </xsl:for-each>
      </div>

<!-- hit parent -->
      <xsl:if test="../../../../structure/parents/parent/@xlink:href">
        <div class="hit_source">
          <span class="label_parent">
            <xsl:value-of select="'aus: '" />
          </span>
          <xsl:call-template name="objectLink">
            <xsl:with-param name="obj_id" select="../../../../structure/parents/parent/@xlink:href" />
          </xsl:call-template>
        </div>
      </xsl:if>

<!-- hit abstract -->
      <div class="hit_abstract">
        <xsl:if test="mods:abstract[not(@altFormat)]">
          <xsl:choose>
            <xsl:when test="mods:abstract[not(@altFormat)][@xml:lang=$CurrentLang]">
              <xsl:value-of select="mcrstringutils:shorten(mods:abstract[not(@altFormat)][@xml:lang=$CurrentLang][1],300)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mcrstringutils:shorten(mods:abstract[not(@altFormat)][1],300)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </div>

<!-- hit publisher -->
      <xsl:if test="//mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.published'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo/mods:publisher" />
        </div>
      </xsl:if>

      <xsl:if test="//mods:originInfo[@eventType='creation']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.publisher.creation'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo[@eventType='creation']/mods:publisher" />
        </div>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
