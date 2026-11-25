<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrobject="http://www.mycore.de/xslt/object"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/mir/guidance-panel/functions/mirguidancepanel.xsl"/>

  <xsl:param name="CurrentLang"/>
  <xsl:param name="DefaultLang"/>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template name="render-guidance-panels">
    <xsl:param name="object-id" as="xs:string"/>
    <xsl:param name="marketing-url" as="xs:string?"/>
    <xsl:if test="mirguidancepanel:is-readable($object-id)">
      <xsl:variable name="mycoreobject" select="mcrobject:get($object-id)/mycoreobject" as="element(mycoreobject)?"/>
      <xsl:for-each select="$mycoreobject/structure/derobjects
        /derobject[classification[@classid='derivate_types'][@categid='guidance']]">
        <xsl:call-template name="render-guidance-panel">
          <xsl:with-param name="mycoreobject" select="$mycoreobject"/>
          <xsl:with-param name="object-id" select="$object-id"/>
          <xsl:with-param name="derivate-id" select="string(@xlink:href)"/>
          <xsl:with-param name="marketing-url" select="$marketing-url"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel">
    <xsl:param name="mycoreobject" as="element(mycoreobject)"/>
    <xsl:param name="object-id" as="xs:string"/>
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="marketing-url" as="xs:string?"/>
    <xsl:variable name="can-read-object" select="mirguidancepanel:is-readable($object-id)"/>
    <xsl:variable name="can-read-derivate" select="mirguidancepanel:is-readable($derivate-id)"/>
    <xsl:variable name="main-file" select="normalize-space(mcrderivate:get-main-file($derivate-id))"/>
    <xsl:variable name="has-main-file" select="boolean($main-file)" as="xs:boolean"/>
    <xsl:variable name="guidance" select="if ($can-read-object and $can-read-derivate and $has-main-file)
      then mcrderivate:get-file($derivate-id, $main-file)/guidance else ()"/>
    <xsl:if test="$guidance">
      <xsl:variable name="title" select="mirguidancepanel:or-else(
      mirguidancepanel:label($guidance/title/label, $CurrentLang, $DefaultLang), $object-id)"/>
      <xsl:variable name="bref-base" select="mirguidancepanel:rel-path-segment($guidance/@bref-base)"/>
      <xsl:where-populated>
        <div class="mir-guidance-banner mb-3">
          <xsl:for-each select="mirguidancepanel:select-one($guidance/banners, 'banner', $CurrentLang)">
            <xsl:call-template name="render-guidance-panel-banner">
              <xsl:with-param name="object-id" select="$object-id"/>
              <xsl:with-param name="derivate-id" select="$derivate-id"/>
              <xsl:with-param name="main-file" select="$main-file"/>
              <xsl:with-param name="banner" select="."/>
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="bref-base" select="$bref-base"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
      </xsl:where-populated>
      <xsl:where-populated>
        <div class="mir-guidance-buttons mb-3">
          <xsl:for-each select="mirguidancepanel:select-one($guidance/buttons, 'about-button', $CurrentLang)">
            <xsl:call-template name="render-guidance-panel-about-button">
              <xsl:with-param name="mycoreobject" select="$mycoreobject"/>
              <xsl:with-param name="derivate-id" select="$derivate-id"/>
              <xsl:with-param name="main-file" select="$main-file"/>
              <xsl:with-param name="about-button" select="."/>
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="bref-base" select="$bref-base"/>
            </xsl:call-template>
          </xsl:for-each>
          <xsl:if test="normalize-space($marketing-url)">
            <xsl:for-each select="mirguidancepanel:select-one($guidance/buttons, 'marketing-button', $CurrentLang)">
              <xsl:call-template name="render-guidance-panel-marketing-button">
                <xsl:with-param name="marketing-button" select="."/>
                <xsl:with-param name="marketing-url" select="$marketing-url"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:if>
        </div>
      </xsl:where-populated>
      <div class="mir-guidance-items">
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <xsl:value-of select="$title"/>
            </h3>
          </div>
          <div class="card-body">
            <ul class="mb-0">
              <xsl:for-each select="mirguidancepanel:select-all($guidance/items, 'item', $CurrentLang)">
                <xsl:call-template name="render-guidance-panel-item">
                  <xsl:with-param name="derivate-id" select="$derivate-id"/>
                  <xsl:with-param name="main-file" select="$main-file"/>
                  <xsl:with-param name="item" select="."/>
                  <xsl:with-param name="bref-base" select="$bref-base"/>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:if test="mirguidancepanel:is-enabled('RSS')">
                <xsl:call-template name="render-guidance-panel-rss-item">
                  <xsl:with-param name="object-id" select="$object-id"/>
                </xsl:call-template>
              </xsl:if>
            </ul>
          </div>
          <xsl:variable name="search" select="normalize-space($guidance/items/@search)"/>
          <xsl:if test="not($search) or lower-case($search)='true'">
            <div class="card-footer">
              <xsl:call-template name="render-guidance-panel-search-form">
                <xsl:with-param name="object-id" select="$object-id"/>
                <xsl:with-param name="derivate-id" select="$derivate-id"/>
                <xsl:with-param name="title" select="$title"/>
              </xsl:call-template>
            </div>
          </xsl:if>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel-banner">
    <xsl:param name="object-id" as="xs:string"/>
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="banner" as="element(banner)"/>
    <xsl:param name="title" as="xs:string"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:variable name="link" select="mirguidancepanel:select-one($banner, 'link', $CurrentLang)"/>
    <xsl:variable name="href">
      <xsl:call-template name="choose-link-href">
        <xsl:with-param name="derivate-id" select="$derivate-id"/>
        <xsl:with-param name="main-file" select="$main-file"/>
        <xsl:with-param name="link" select="$link"/>
        <xsl:with-param name="bref-base" select="$bref-base"/>
        <xsl:with-param name="default" select="concat($WebApplicationBaseURL, 'receive/', $object-id)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="image" select="mirguidancepanel:select-one($banner, 'image', $CurrentLang)"/>
    <xsl:variable name="src">
      <xsl:call-template name="choose-image-src">
        <xsl:with-param name="derivate-id" select="$derivate-id"/>
        <xsl:with-param name="main-file" select="$main-file"/>
        <xsl:with-param name="image" select="$image"/>
        <xsl:with-param name="bref-base" select="$bref-base"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="alt" select="mirguidancepanel:or-else(normalize-space($image/@alt), $title)"/>
    <xsl:choose>
      <xsl:when test="normalize-space($href)">
        <a class="mir-guidance-banner-image" href="{$href}">
          <img src="{$src}" class="card-img-top" alt="{$alt}"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="mir-guidance-banner-image">
          <img src="{$src}" class="card-img-top" alt="{$alt}"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="mirguidancepanel:select-one($banner, 'small-print', $CurrentLang)">
      <small class="mir-guidance-banner-small-print d-block text-center">
        <xsl:copy-of select="./node()"/>
      </small>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="render-guidance-panel-about-button">
    <xsl:param name="mycoreobject" as="element(mycoreobject)"/>
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="about-button" as="element(about-button)"/>
    <xsl:param name="title" as="xs:string"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:variable name="link" select="mirguidancepanel:select-one($about-button, 'link', $CurrentLang)"/>
    <xsl:variable name="href">
      <xsl:call-template name="choose-link-href">
        <xsl:with-param name="derivate-id" select="$derivate-id"/>
        <xsl:with-param name="main-file" select="$main-file"/>
        <xsl:with-param name="link" select="$link"/>
        <xsl:with-param name="bref-base" select="$bref-base"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="mode" select="($about-button/@mode, 'genre')[1]"/>
    <xsl:variable name="mods" select="$mycoreobject/metadata//mods:mods"/>
    <xsl:variable name="modsGenre" select="substring-after($mods/mods:genre[@type='intern']/@valueURI,'#')"/>
    <xsl:variable name="genre" select="(about-button/@genre, $modsGenre)"/>
    <xsl:variable name="label">
      <xsl:value-of select="mcri18n:translate('mir.guidancePanel.about')"/>
      <xsl:choose>
        <xsl:when test="$mode='title'">
          <xsl:value-of select="' '"/>
          <xsl:value-of select="$title"/>
        </xsl:when>
        <xsl:when test="mcri18n:exists(concat('mir.guidancePanel.about.', $genre))">
          <xsl:value-of select="' '"/>
          <xsl:value-of select="mcri18n:translate(concat('mir.guidancePanel.about.', $genre))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="type" select="($about-button/@type, 'primary')[1]"/>
      <div class="mir-guidance-button-about mb-1">
        <a href="{$href}" class="btn btn-{$type} w-100{if (normalize-space($href)) then '' else ' disabled'}">
          <i aria-hidden="true" class="fas fa-info-circle"/>
          <xsl:value-of select="$label"/>
        </a>
      </div>
  </xsl:template>

  <xsl:template name="render-guidance-panel-marketing-button">
    <xsl:param name="marketing-button" as="element(marketing-button)"/>
    <xsl:param name="marketing-url" as="xs:string"/>
    <xsl:variable name="type" select="($marketing-button/@type, 'primary')[1]"/>
    <xsl:variable name="href" select="$marketing-url"/>
    <div class="mir-guidance-button-marketing mb-1">
      <a href="{$href}" class="btn btn-{$type} w-100{if (normalize-space($href)) then '' else ' disabled'}">
        <i aria-hidden="true" class="fas fa-shopping-cart"/>
        <xsl:value-of select="mcri18n:translate('mir.guidancePanel.buyPrintedCopy')"/>
      </a>
    </div>
  </xsl:template>

  <xsl:template name="render-guidance-panel-search-form">
    <xsl:param name="object-id" as="xs:string"/>
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="title" as="xs:string"/>
    <!-- unique, a page may contain several panels -->
    <xsl:variable name="search-label" select="mcri18n:translate-with-params('mir.guidancePanel.search', $title)"/>
    <form role="search" action="{$ServletsBaseURL}solr/find">
      <xsl:if test="not(mirguidancepanel:is-enabled('SearchPanel')) and mirguidancepanel:is-enabled('SearchFacet')">
        <input type="hidden" name="facet.field" value="{{!facet.prefix={$object-id}}}mods.relatedItem.root"/>
        <input type="hidden" name="facet.label.{$object-id}" value="{$title}"/>
      </xsl:if>
      <input type="hidden" name="fq" value="mods.relatedItem.root:{$object-id}"/>
      <xsl:variable name="input-id" select="concat('mir-guidance-panel-search-', $derivate-id)"/>
      <label class="visually-hidden" for="{$input-id}">
        <xsl:value-of select="$search-label"/>
      </label>
      <div class="input-group">
        <input id="{$input-id}" type="text" name="condQuery" class="form-control" placeholder="{$search-label}"/>
        <button class="btn btn-primary" type="submit" aria-label="{$search-label}">
          <i class="fas fa-search" aria-hidden="true"/>
        </button>
      </div>
    </form>
  </xsl:template>

  <xsl:template name="render-guidance-panel-rss-item">
    <xsl:param name="object-id" as="xs:string"/>
    <li>
      <a href="{$WebApplicationBaseURL}receive/{$object-id}?XSL.Style=rss">
        <i class="fas fa-rss" aria-hidden="true"/>
        <xsl:value-of select="concat(' ', mcri18n:translate('mir.guidancePanel.rss'))"/>
      </a>
    </li>
  </xsl:template>

  <xsl:template name="render-guidance-panel-item">
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="item" as="element(item)"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:variable name="link" select="mirguidancepanel:select-one($item, 'link', $CurrentLang)"/>
    <xsl:variable name="href">
      <xsl:call-template name="choose-link-href">
        <xsl:with-param name="derivate-id" select="$derivate-id"/>
        <xsl:with-param name="main-file" select="$main-file"/>
        <xsl:with-param name="link" select="$link"/>
        <xsl:with-param name="bref-base" select="$bref-base"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="label" select="mirguidancepanel:or-else(
    mirguidancepanel:label($item/label, $CurrentLang, $DefaultLang), 'n/a')"/>
    <xsl:if test="normalize-space($label)">
      <li>
        <xsl:choose>
          <xsl:when test="normalize-space($href)">
            <a href="{$href}">
              <xsl:value-of select="$label"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$label"/>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="choose-link-href">
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="link" as="element(link)?"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:param name="default" as="xs:string?"/>
    <xsl:if test="count(($link/@href, $link/@bref, $link/@ref, $link/@file)) gt 1">
      <xsl:message terminate="no" expand-text="yes">
        Warning: Element link in file {$derivate-id}/{$main-file} has conflicting attributes:
        {string-join(($link/@href, $link/@bref, $link/@ref, $link/@file)
        /concat(name(), '=&quot;', normalize-space(.), '&quot;'), ' / ')}
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$link/@href">
        <xsl:value-of select="$link/@href"/>
      </xsl:when>
      <xsl:when test="$link/@bref">
        <xsl:value-of select="concat($WebApplicationBaseURL, $bref-base, mirguidancepanel:rel-path($link/@bref))"/>
      </xsl:when>
      <xsl:when test="$link/@ref">
        <xsl:value-of select="concat($WebApplicationBaseURL, mirguidancepanel:rel-path($link/@ref))"/>
      </xsl:when>
      <xsl:when test="$link/@file">
        <xsl:variable name="servlet-path" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
        <xsl:value-of select="concat($WebApplicationBaseURL, $servlet-path, $derivate-id, '/', $link/@file)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="choose-image-src">
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="image" as="element(image)?"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:if test="count(($image/@href, $image/@bref, $image/@ref, $image/@file)) gt 1">
      <xsl:message terminate="no" expand-text="yes">
        Warning: Element image in file {$derivate-id}/{$main-file} has conflicting attributes:
        {string-join(($image/@href, $image/@bref, $image/@ref, $image/@file)
        /concat(name(), '=&quot;', normalize-space(.), '&quot;'), ' / ')}.
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$image/@href">
        <xsl:value-of select="$image/@href"/>
      </xsl:when>
      <xsl:when test="$image/@bref">
        <xsl:value-of select="concat($WebApplicationBaseURL, $bref-base, $image/@bref)"/>
      </xsl:when>
      <xsl:when test="$image/@ref">
        <xsl:value-of select="concat($WebApplicationBaseURL, $image/@ref)"/>
      </xsl:when>
      <xsl:when test="$image/@file">
        <xsl:variable name="servlet-path" select="'servlets/MCRFileNodeServlet/'"/>
        <xsl:value-of select="concat($WebApplicationBaseURL, $servlet-path, $derivate-id, '/', $image/@file)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
