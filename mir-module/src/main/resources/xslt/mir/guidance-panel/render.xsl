<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrobject="http://www.mycore.de/xslt/object"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/mir/guidance-panel/functions/mirguidancepanel.xsl" />

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template name="render-guidance-panels">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:if test="mirguidancepanel:is-readable($object-id)">
      <xsl:for-each select="mcrobject:get($object-id)/mycoreobject/structure/derobjects
        /derobject[classification[@classid = 'derivate_types'][@categid = 'guidance']]">
        <xsl:call-template name="render-guidance-panel">
          <xsl:with-param name="object-id" select="$object-id" />
          <xsl:with-param name="derivate-id" select="string(@xlink:href)" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:variable name="can-read-object" select="mirguidancepanel:is-readable($object-id)"/>
    <xsl:variable name="can-read-derivate" select="mirguidancepanel:is-readable($derivate-id)"/>
    <xsl:variable name="main-file" select="normalize-space(mcrderivate:get-main-file($derivate-id))"/>
    <xsl:variable name="has-main-file" select="boolean($main-file)" as="xs:boolean"/>
    <xsl:variable name="guidance" select="if ($can-read-object and $can-read-derivate and $has-main-file)
      then mcrderivate:get-file($derivate-id, $main-file)/guidance else ()"/>
    <xsl:if test="$guidance">
      <xsl:variable name="title" select="mirguidancepanel:label($guidance/lebels/label, $CurrentLang, $DefaultLang)" />
      <div class="mir-guidance-panel">
        <div class="card">
          <xsl:if test="normalize-space($guidance/@banner)">
            <xsl:call-template name="render-guidance-panel-banner">
              <xsl:with-param name="object-id" select="$object-id" />
              <xsl:with-param name="banner" select="string($guidance/@banner)" />
              <xsl:with-param name="title" select="$title" />
            </xsl:call-template>
          </xsl:if>
          <div class="card-header">
            <h3 class="card-title">
              <xsl:value-of select="$title" />
            </h3>
          </div>
          <div class="card-body">
            <ul>
              <xsl:for-each select="$guidance/items/item">
                <xsl:call-template name="render-guidance-panel-item">
                  <xsl:with-param name="derivate-id" select="$derivate-id" />
                  <xsl:with-param name="item" select="." />
                </xsl:call-template>
              </xsl:for-each>
              <xsl:if test="mirguidancepanel:is-rss-enabled()">
                <xsl:call-template name="render-guidance-panel-rss-item">
                  <xsl:with-param name="object-id" select="$object-id" />
                </xsl:call-template>
              </xsl:if>
            </ul>
          </div>
          <div class="card-footer">
            <xsl:call-template name="render-guidance-panel-search-form">
              <xsl:with-param name="object-id" select="$object-id" />
              <xsl:with-param name="derivate-id" select="$derivate-id" />
              <xsl:with-param name="title" select="$title" />
            </xsl:call-template>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel-banner">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="banner" as="xs:string" />
    <xsl:param name="title" as="xs:string" />
    <a class="mir-guidance-panel-banner" href="{$WebApplicationBaseURL}receive/{$object-id}">
      <img src="{$WebApplicationBaseURL}{$banner}" class="card-img-top" alt="{$title}" />
    </a>
  </xsl:template>

  <xsl:template name="render-guidance-panel-search-form">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="title" as="xs:string" />
    <!-- unique, a page may contain several panels -->
    <xsl:variable name="input-id" select="concat('mir-guidance-panel-search-', $derivate-id)" />
    <xsl:variable name="search-label" select="mcri18n:translate-with-params('mir.guidancePanel.search', $title)" />
    <form role="search" action="{$ServletsBaseURL}solr/find">
      <input type="hidden" name="fq" value="mods.relatedItem.root:{$object-id}" />
      <label class="visually-hidden" for="{$input-id}">
        <xsl:value-of select="$search-label" />
      </label>
      <div class="input-group">
        <input id="{$input-id}" type="text" name="condQuery" class="form-control" placeholder="{$search-label}" />
        <button class="btn btn-primary" type="submit" aria-label="{$search-label}">
          <i class="fas fa-search" aria-hidden="true" />
        </button>
      </div>
    </form>
  </xsl:template>

  <xsl:template name="render-guidance-panel-rss-item">
    <xsl:param name="object-id" as="xs:string" />
    <li>
      <a href="{$WebApplicationBaseURL}receive/{$object-id}?XSL.Style=rss">
        <i class="fas fa-rss" aria-hidden="true" />
        <xsl:value-of select="concat(' ', mcri18n:translate('mir.guidancePanel.rss'))" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="render-guidance-panel-item">
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="item" as="element(item)" />
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="$item/@href">
          <xsl:value-of select="$item/@href"/>
        </xsl:when>
        <xsl:when test="$item/@ref">
          <xsl:value-of select="concat($WebApplicationBaseURL, $item/@ref)"/>
        </xsl:when>
        <xsl:when test="$item/@file">
          <xsl:variable name="derivateContentServletPath" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
          <xsl:value-of select="concat($WebApplicationBaseURL, $derivateContentServletPath,$derivate-id, '/', $item/@file)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="label" select="mirguidancepanel:label($item/label, $CurrentLang, $DefaultLang)"/>
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
  </xsl:template>

</xsl:stylesheet>
