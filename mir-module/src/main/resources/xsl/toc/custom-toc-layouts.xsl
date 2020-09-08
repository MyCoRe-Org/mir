<?xml version="1.0" encoding="UTF-8"?>

<!-- Custom table of contents layouts to display levels and publications -->
<!-- Default templates may be overwritten by higher priority custom templates -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xalan i18n"
>

  <xsl:param name="CurrentLang" select="'de'" />

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
    <xsl:for-each select="field[@name='mir.toc.title']">
      <xsl:text>: </xsl:text>
      <a href="{$WebApplicationBaseURL}receive/{../@id}">
        <xsl:value-of select="." />
      </a>
    </xsl:for-each>
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

  <xsl:template match="level[@field='mir.toc.host.volume']/item" mode="label" priority="1">
    <xsl:value-of select="i18n:translate('mir.details.volume.journal')" />
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
    <xsl:value-of select="i18n:translate('mir.details.issue')" />
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
        <xsl:with-param name="showVolume" select="'true'" />
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
    <xsl:param name="class" />
    <xsl:param name="showVolume" select="'false'" />

    <h4 class="{$class} mir-toc-section-title">
      <a href="{$WebApplicationBaseURL}receive/{@id}">
        <xsl:if test="$showVolume='true' and (field[@name='mir.toc.series.volume'] or field[@name='mir.toc.host.volume'])">
          <xsl:choose>
            <xsl:when test="field[@name='mir.toc.host.volume']">
              <xsl:value-of select="field[@name='mir.toc.host.volume']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="field[@name='mir.toc.series.volume']" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> - </xsl:text>
        </xsl:if>
        <xsl:value-of select="field[@name='mir.toc.title']" />
      </a>
    </h4>
  </xsl:template>

  <!-- ========== authors ========== -->

  <xsl:template name="toc.authors">
    <xsl:param name="class" />

    <!-- if no authors, then no div too-->
    <xsl:for-each select="field[@name='mir.toc.authors']">
      <div class="{$class} mir-toc-section-author">
        <xsl:value-of select="." />
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- =========== page ========= -->

  <xsl:template name="toc.page">
    <xsl:param name="class" />

    <!-- if no page, then no div too-->
    <xsl:for-each select="field[starts-with(@name,'mir.toc.host.page')]">
      <div class="{$class} mir-toc-section-page">
        <xsl:value-of select="i18n:translate('mir.pages.abbreviated.single')" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="." />
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- =========== day.month ========= -->

  <xsl:template name="toc.day.month">
    <xsl:param name="class" />

    <div class="{$class}">
      <xsl:for-each select="field[@name='mods.dateIssued'][1]">
        <xsl:call-template name="formatISODate">
          <xsl:with-param name="date" select="." />
          <xsl:with-param name="format">
            <xsl:choose>
              <xsl:when test="$CurrentLang='de'">dd.MM.</xsl:when>
              <xsl:otherwise>MM-dd</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>

 </xsl:stylesheet>
