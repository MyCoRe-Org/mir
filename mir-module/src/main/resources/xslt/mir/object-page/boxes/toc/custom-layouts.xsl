<?xml version="1.0" encoding="UTF-8"?>

<!-- Custom table of contents layouts to display levels and publications -->
<!-- Default templates may be overwritten by higher priority custom templates -->

<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <!-- ====================
       level default:
       - - - - - - - - - -
       value
  -or- value(linked)
  -or- value: title(linked)
       authors
       ==================== -->

  <xsl:template match="item[doc[not(field[@name='mir.toc.title'])]]">
    <a href="{$WebApplicationBaseURL}receive/{doc/@id}">
      <xsl:apply-templates select="." mode="text" />
    </a>
  </xsl:template>

  <xsl:template match="item">
    <xsl:apply-templates select="." mode="text" />
  </xsl:template>

  <xsl:template match="item" mode="text">
    <span class="mir-toc-section-label">
      <xsl:apply-templates select="." mode="label" />
    </span>
  </xsl:template>

  <xsl:template match="item" mode="label">
    <xsl:value-of select="@value" />
    <xsl:apply-templates select="doc" />
  </xsl:template>

  <xsl:template match="item/doc">
    <xsl:text>: </xsl:text>
    <a href="{$WebApplicationBaseURL}receive/{@id}">
      <xsl:choose>
        <xsl:when test="string-length(field[@name='mir.toc.title']) &gt; 0">
          <xsl:value-of select="field[@name='mir.toc.title']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="field[@name='search_result_link_text']" />
        </xsl:otherwise>
      </xsl:choose>
    </a>
    <xsl:for-each select="field[@name='mir.toc.authors']">
      <br />
      <xsl:value-of select="." />
    </xsl:for-each>
  </xsl:template>

  <!-- ====================
       volume level:
       - - - - - - - - - -
       Vol. #
  -or- Vol. #: title(linked)
       authors
       ==================== -->

  <xsl:template match="level[@field='mir.toc.series.volume']/item" mode="label" priority="1">
    <xsl:value-of select="mcri18n:translate('mir.details.volume.series')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@value" />
    <xsl:apply-templates select="doc" />
  </xsl:template>

  <!-- ====================
       volume level:
       - - - - - - - - - -
       Vol. #
  -or- Vol. #: title(linked)
       authors
       ==================== -->

  <xsl:template match="level[@field='mir.toc.host.volume']/item" mode="label" priority="1">
    <xsl:value-of select="mcri18n:translate('mir.details.volume.journal')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@value" />
    <xsl:for-each select="doc/field[@name='mods.yearIssued']">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="text()" />
      <xsl:text>)</xsl:text>
    </xsl:for-each>
    <xsl:apply-templates select="doc" />
  </xsl:template>

  <!-- ====================
       issue level:
       - - - - - - - - - -
       No. #
  -or- No. #: title(linked)
       authors
       ==================== -->

  <xsl:template match="level[@field='mir.toc.host.issue']/item" mode="label" priority="1">
    <xsl:value-of select="mcri18n:translate('mir.details.issue')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@value" />
    <xsl:apply-templates select="doc" />
  </xsl:template>

  <!-- ====================
       default publication:
       - - - - - - - - - -
       linked title    page
       authors
       ==================== -->

  <xsl:template match="publications/doc" priority="1">
    <div class="row">
      <xsl:call-template name="toc.title">
        <xsl:with-param name="class">col-10</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.page">
        <xsl:with-param name="class">col-2</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.authors">
        <xsl:with-param name="class">col-10</xsl:with-param>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- ====================
       legacy publication:
       - - - - - - - - - -
       [vol -] title   page
       authors
       ==================== -->
  <xsl:template match="toc[@layout='legacy']//publications/doc" priority="2">
    <div class="row">
      <xsl:call-template name="toc.title">
        <xsl:with-param name="class">col-10</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.page">
        <xsl:with-param name="class">col-2</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.authors">
        <xsl:with-param name="class">col-10</xsl:with-param>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- ====================
       blog article:
       - - - - - - - - - -
       date    linked title
               authors
       ==================== -->

  <xsl:template match="toc[@layout='blog']//publications/doc" priority="2">
    <div class="row">
      <xsl:call-template name="toc.day.month">
        <xsl:with-param name="class">col-1</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.title">
        <xsl:with-param name="class">col-11</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="toc.authors">
        <xsl:with-param name="class">offset-1 col-11</xsl:with-param>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- ========== title ========== -->

  <xsl:template name="toc.title">
    <xsl:param name="class" select="''" />

    <h4>
      <xsl:attribute name="class">
        <xsl:text>mir-toc-section-title</xsl:text>
        <xsl:if test="string-length($class) &gt; 0">
          <xsl:value-of select="concat(' ', $class)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="field[@name='mir.toc.series.volume.top']">
          <xsl:value-of select="mcri18n:translate('mir.details.volume.series')" />
          <xsl:value-of select="concat(' ', field[@name='mir.toc.series.volume.top'], ': ')" />
        </xsl:when>
        <xsl:when test="field[@name='mir.toc.host.volume.top']">
          <xsl:value-of select="mcri18n:translate('mir.details.volume.journal')" />
          <xsl:value-of select="concat(' ', field[@name='mir.toc.host.volume.top'], ': ')" />
        </xsl:when>
        <xsl:when test="field[@name='mir.toc.host.issue.top']">
          <xsl:value-of select="mcri18n:translate('mir.details.issue')" />
          <xsl:value-of select="concat(' ', field[@name='mir.toc.host.issue.top'], ': ')" />
        </xsl:when>
        <xsl:when test="field[@name='mir.toc.host.articleNumber.top']">
          <xsl:value-of select="concat('#', field[@name='mir.toc.host.articleNumber.top'], ': ')" />
        </xsl:when>
      </xsl:choose>
      <a href="{$WebApplicationBaseURL}receive/{@id}">
        <xsl:choose>
          <xsl:when test="string-length(field[@name='mir.toc.title']) &gt; 0">
            <xsl:value-of select="field[@name='mir.toc.title']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="field[@name='search_result_link_text']" />
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </h4>
  </xsl:template>

  <!-- ========== authors ========== -->

  <xsl:template name="toc.authors">
    <xsl:param name="class" select="''" />

    <!-- if no authors, then no div too-->
    <xsl:for-each select="field[@name='mir.toc.authors']">
      <div>
        <xsl:attribute name="class">
          <xsl:text>mir-toc-section-author</xsl:text>
          <xsl:if test="string-length($class) &gt; 0">
            <xsl:value-of select="concat(' ', $class)" />
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="." />
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- =========== page ========= -->

  <xsl:template name="toc.page">
    <xsl:param name="class" select="''" />

    <!-- if no page, then no div too-->
    <xsl:for-each select="field[starts-with(@name, 'mir.toc.host.page')]">
      <div>
        <xsl:attribute name="class">
          <xsl:text>mir-toc-section-page</xsl:text>
          <xsl:if test="string-length($class) &gt; 0">
            <xsl:value-of select="concat(' ', $class)" />
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="mcri18n:translate('mir.pages.abbreviated.single')" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="." />
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- =========== day.month ========= -->

  <xsl:template name="toc.day.month">
    <xsl:param name="class" select="''" />

    <div class="{$class}">
      <xsl:attribute name="class">
        <xsl:text>mir-toc-section-date</xsl:text>
        <xsl:if test="string-length($class) &gt; 0">
          <xsl:value-of select="concat(' ', $class)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:for-each select="field[@name='mods.dateIssued'][1]">
        <xsl:value-of
          select="
            if (. castable as xs:date) then
              format-date(xs:date(.), if ($CurrentLang = 'de') then '[D01].[M01].' else '[M01]-[D01]')
            else
              .
          " />
      </xsl:for-each>
    </div>
  </xsl:template>

</xsl:stylesheet>
