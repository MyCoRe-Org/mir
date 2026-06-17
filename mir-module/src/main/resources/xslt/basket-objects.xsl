<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n">

  <xsl:import href="resource:xslt/orcid/mir-orcid.xsl" />

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />
  <xsl:include href="resource:xslt/csl-export-gui.xsl" />
  <xsl:include href="xslInclude:objectTypes" />

  <xsl:variable name="PageTitle" select="mcri18n:translate(concat('basket.title.', /basket/@type))" />
  <xsl:variable name="Type" select="'mods'" />

  <xsl:template match="/basket">
    <div id="basket">
      <div id="options" class="btn-group float-end">
        <xsl:call-template name="options" />
      </div>
      <h2>
        <xsl:value-of select="$PageTitle" />
      </h2>
      <xsl:call-template name="basketNumEntries" />
      <xsl:call-template name="export-csl" />
      <xsl:call-template name="basketEntries" />
    </div>
    <xsl:if test="$isOrcidEnabled">
      <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-basket.js" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="export-csl">
    <div class="row result_export">
      <div class="col-12">
        <xsl:if test="count(entry) &gt; 0">
          <xsl:call-template name="exportGUI">
            <xsl:with-param name="type" select="'basket'" />
          </xsl:call-template>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="basketNumEntries">
    <p class="lead">
      <xsl:choose>
        <xsl:when test="count(entry) = 0">
          <xsl:value-of select="mcri18n:translate('basket.numEntries.none')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:when test="count(entry) = 1">
          <xsl:value-of select="mcri18n:translate('basket.numEntries.one')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcri18n:translate('basket.numEntries.many', count(*))" disable-output-escaping="yes" />
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

  <xsl:template name="basketEntries">
    <div class="result_body">
      <div class="result_list">
        <div id="hit_list">
          <xsl:apply-templates select="entry" />
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="hitNumberOnPage" select="count(preceding-sibling::*[name() = name(.)]) + 1" />
    <div class="hit_item">
      <div class="row hit_item_head">
        <div class="col-12">
          <div class="hit_counter">
            <xsl:value-of select="$hitNumberOnPage" />
          </div>
          <div class="hit_options float-end">
            <div class="btn-group">
              <xsl:apply-templates mode="basketButtonsUpDownDelete" select="." />
            </div>
          </div>
        </div>
      </div>
      <div class="row hit_item_body">
        <div class="col-12">
          <xsl:choose>
            <xsl:when test="*[not(name()='comment')]">
              <xsl:apply-templates  mode="basketContent" select="*[not(name()='comment')]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="basketContent" select="document(@uri)/*" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates mode="basketContent" select="comment" />
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="entry" mode="basketButtonsUpDownDelete">
    <xsl:variable name="notFirst" select="count(preceding-sibling::entry) &gt; 0" />
    <xsl:variable name="notLast" select="count(following-sibling::entry) &gt; 0" />
    <div class="btn-group">
      <xsl:apply-templates select="." mode="button">
        <xsl:with-param name="action" select="'up'" />
        <xsl:with-param name="icon" select="'arrow-up'" />
        <xsl:with-param name="condition" select="$notFirst" />
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="button">
        <xsl:with-param name="action" select="'down'" />
        <xsl:with-param name="icon" select="'arrow-down'" />
        <xsl:with-param name="condition" select="$notLast" />
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="button">
        <xsl:with-param name="action" select="'remove'" />
        <xsl:with-param name="icon" select="'times'" />
        <xsl:with-param name="class" select="'btn-warning'" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="entry" mode="button">
    <xsl:param name="action" />
    <xsl:param name="icon" select="'question-circle'" />
    <xsl:param name="class" select="'btn-secondary'" />
    <xsl:param name="condition" select="true()" />
    <xsl:choose>
      <xsl:when test="$condition">
        <a
          href="MCRBasketServlet?action={$action}&amp;type={/basket/@type}&amp;id={@id}"
          class="btn btn-small {$class}"
          title="{mcri18n:translate(concat('basket.button.', $action))}">
          <i class="fas fa-{$icon}"></i>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a
          href="#"
          class="btn btn-small btn-secondary disabled"
          title="{mcri18n:translate(concat('basket.button.', $action))}">
          <i class="fas fa-{$icon}"></i>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="options">
    <a
      href="{$ServletsBaseURL}MCRBasketServlet?type={@type}&amp;action=clear&amp;redirect=referer"
      class="btn btn-danger btn-sm">
      <span class="fas fa-trash-alt me-1"></span>
      <xsl:value-of select="mcri18n:translate('basket.clear')" />
    </a>
  </xsl:template>

</xsl:stylesheet>
