<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirguidancepanel:is-enabled" as="xs:boolean">
    <xsl:sequence select="mcrproperty:get-boolean('MIR.GuidancePanel.Enabled')" />
  </xsl:function>

  <xsl:function name="mirguidancepanel:is-enabled" as="xs:boolean">
    <xsl:param name="feature" as="xs:string" />
    <xsl:sequence select="mcrproperty:get-boolean(concat('MIR.GuidancePanel.', $feature,'.Enabled'))" />
  </xsl:function>

  <!--
    true if the id is a MyCoRe ID readable by the current user; the id may come from request parameters,
    the format is checked first because checkPermission fails for ids containing a colon
  -->
  <xsl:function name="mirguidancepanel:is-readable" as="xs:boolean">
    <xsl:param name="id" as="xs:string" />
    <xsl:sequence select="matches($id, '^[a-zA-Z][a-zA-Z0-9]*_[a-zA-Z0-9]+_[0-9]+$')
      and mcracl:check-permission($id, 'read')" />
  </xsl:function>

  <!-- label in the current language, falls back to the default language and then to the first label -->
  <xsl:function name="mirguidancepanel:label" as="xs:string">
    <xsl:param name="labels" as="element(label)*" />
    <xsl:param name="current-lang" as="xs:string" />
    <xsl:param name="default-lang" as="xs:string" />
    <xsl:sequence select="string(($labels[lang($current-lang)], $labels[lang($default-lang)], $labels)[1])" />
  </xsl:function>

  <!-- returns the fallback if the value is empty -->
  <xsl:function name="mirguidancepanel:non-empty-or-else" as="xs:string">
    <xsl:param name="value" as="xs:string" />
    <xsl:param name="fallback" as="xs:string" />
    <xsl:sequence select="($value[.], $fallback)[1]" />
  </xsl:function>

  <!-- select first child element with given name and, preferably, current language or no language -->
  <xsl:function name="mirguidancepanel:select-one" as="element()?">
    <xsl:param name="base" as="element()?"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="current-lang" as="xs:string"/>
    <xsl:sequence select="($base/*[name()=$name][lang($current-lang)], $base/*[name()=$name][not(@xml:lang)])[1]"/>
  </xsl:function>

  <!-- select child elements with given name and current language or no language -->
  <xsl:function name="mirguidancepanel:select-all" as="element()*">
    <xsl:param name="base" as="element()?"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="current-lang" as="xs:string"/>
    <xsl:sequence select="($base/*[name()=$name][lang($current-lang)] | $base/*[name()=$name][not(@xml:lang)])"/>
  </xsl:function>

  <!-- normalizes and removes leading slash, so the value can be appended to, for example $WebApplicationBaseURL -->
  <xsl:function name="mirguidancepanel:rel-path" as="xs:string">
    <xsl:param name="path" as="xs:string?"/>
    <xsl:variable name="normalized-path" select="normalize-space($path)"/>
    <xsl:variable name="rel-path">
      <xsl:if test="$normalized-path">
        <xsl:choose>
          <xsl:when test="starts-with($normalized-path, '/')">
            <xsl:value-of select="substring($normalized-path, 2)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$normalized-path"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:sequence select="($rel-path)"/>
  </xsl:function>

  <!--
    normalizes and removes leading slash, so the value can be appended to, for example $WebApplicationBaseURL
    and adds trailing slash, so another rel-p[ath can be appended
  -->
  <xsl:function name="mirguidancepanel:rel-path-segment" as="xs:string">
    <xsl:param name="path" as="xs:string?"/>
    <xsl:variable name="normalized-path" select="normalize-space($path)"/>
    <xsl:variable name="rel-path-segment">
      <xsl:if test="$normalized-path">
        <xsl:choose>
          <xsl:when test="starts-with($normalized-path, '/') and string-length($normalized-path) gt 1">
            <xsl:value-of select="substring($normalized-path, 2)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$normalized-path"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(ends-with($normalized-path, '/'))">
          <xsl:value-of select="'/'"/>
        </xsl:if>
      </xsl:if>
    </xsl:variable>
    <xsl:sequence select="($rel-path-segment)"/>
  </xsl:function>

  <!--
    choose the href for a link element, considering, in order:
    - the href-attribute as an absolute URL
    - the bref-attribute as a relative URL in conjunction with the base URL provided as web-application-base-url
      and the base path provided as bref-base
    - the ref-attribute as a relative URL in conjunction with the base URL provided as web-application-base-url
    - the file attribute for a file of the derivate in conjunction with the MCRDerivateContentTransformerServlet
    - the default value provided as default
  -->
  <xsl:function name="mirguidancepanel:choose-link-href" as="xs:string">
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="link" as="element(link)?"/>
    <xsl:param name="web-application-base-url" as="xs:string"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:param name="default" as="xs:string"/>
    <xsl:if test="count(($link/@href, $link/@bref, $link/@ref, $link/@file)) gt 1">
      <xsl:message terminate="no" expand-text="yes">
        Warning: Element link in file {$derivate-id}/{$main-file} has conflicting attributes:
        {string-join(($link/@href, $link/@bref, $link/@ref, $link/@file)
        /concat(name(), '=&quot;', normalize-space(.), '&quot;'), ' / ')}
      </xsl:message>
    </xsl:if>
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="$link/@href">
          <xsl:value-of select="$link/@href"/>
        </xsl:when>
        <xsl:when test="$link/@bref">
          <xsl:value-of select="concat($web-application-base-url, $bref-base, mirguidancepanel:rel-path($link/@bref))"/>
        </xsl:when>
        <xsl:when test="$link/@ref">
          <xsl:value-of select="concat($web-application-base-url, mirguidancepanel:rel-path($link/@ref))"/>
        </xsl:when>
        <xsl:when test="$link/@file">
          <xsl:variable name="servlet-path" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
          <xsl:value-of select="concat($web-application-base-url, $servlet-path, $derivate-id, '/', $link/@file)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="(normalize-space($href))"/>
  </xsl:function>

  <!--
    choose the src for an image element, considering, in order:
    - the href-attribute as an absolute URL
    - the bref-attribute as a relative URL in conjunction with the base URL provided as web-application-base-url
      and the base path provided as bref-base
    - the ref-attribute as a relative URL in conjunction with the base URL provided as web-application-base-url
    - the file attribute for a file of the derivate in conjunction with the MCRFileNodeServlet
    - the default value provided as default
  -->
  <xsl:function name="mirguidancepanel:choose-images-src" as="xs:string">
    <xsl:param name="derivate-id" as="xs:string"/>
    <xsl:param name="main-file" as="xs:string"/>
    <xsl:param name="image" as="element(image)?"/>
    <xsl:param name="web-application-base-url" as="xs:string"/>
    <xsl:param name="bref-base" as="xs:string"/>
    <xsl:param name="default" as="xs:string"/>
    <xsl:if test="count(($image/@href, $image/@bref, $image/@ref, $image/@file)) gt 1">
      <xsl:message terminate="no" expand-text="yes">
        Warning: Element image in file {$derivate-id}/{$main-file} has conflicting attributes:
        {string-join(($image/@href, $image/@bref, $image/@ref, $image/@file)
        /concat(name(), '=&quot;', normalize-space(.), '&quot;'), ' / ')}.
      </xsl:message>
    </xsl:if>
    <xsl:variable name="src">
      <xsl:choose>
        <xsl:when test="$image/@href">
          <xsl:value-of select="$image/@href"/>
        </xsl:when>
        <xsl:when test="$image/@bref">
          <xsl:value-of select="concat($web-application-base-url, $bref-base, $image/@bref)"/>
        </xsl:when>
        <xsl:when test="$image/@ref">
          <xsl:value-of select="concat($web-application-base-url, $image/@ref)"/>
        </xsl:when>
        <xsl:when test="$image/@file">
          <xsl:variable name="servlet-path" select="'servlets/MCRFileNodeServlet/'"/>
          <xsl:value-of select="concat($web-application-base-url, $servlet-path, $derivate-id, '/', $image/@file)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="(normalize-space($src))"/>
  </xsl:function>

</xsl:stylesheet>
