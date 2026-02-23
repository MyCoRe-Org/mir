<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xalan xsl">

  <xsl:param name="MIR.TableOfContents.HideTrivialLevel" />
  <xsl:param name="WebApplicationBaseURL" />

  <!-- custom layouts of level items and publications -->
  <xsl:include href="toc/custom-toc-layouts.xsl" />

  <xsl:include href="coreFunctions.xsl" />

  <xsl:template match="toc">
    <!-- show table of contents only if the response returned any documents -->
    <xsl:if test="//doc">
      <div id="toc" class="detail_block">
        <div class="detail_block">
          <h3>
            <xsl:value-of select="mcri18n:translate('mir.metadata.content')"/>

            <!-- links to expand/collapse all toc levels at once -->
            <xsl:if test="count(//item) &gt; 1">
              <span class="float-end" style="font-size:smaller;">
                <a id="tocShowAll" href="#">
                  <xsl:value-of select="mcri18n:translate('mir.abstract.showGroups')" />
                </a>
                <a id="tocHideAll" href="#" style="display:none;">
                  <xsl:value-of select="mcri18n:translate('mir.abstract.hideGroups')" />
                </a>
              </span>
            </xsl:if>
          </h3>

          <!-- show all toc levels and publications  -->
          <xsl:apply-templates select="level|publications" />

          <!-- javascript to expand/collapse toc levels on click -->
          <script src="{$WebApplicationBaseURL}js/mir/toc-layout.js" />
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- if at top level, there is only one group, without deeper levels, just show publications -->
  <xsl:template match="toc[$MIR.TableOfContents.HideTrivialLevel='true']/level[count(item)=1][item[not(level)][publications]]" priority="1">
    <xsl:apply-templates select="item/publications" />
  </xsl:template>

  <!-- show a toc level -->
  <xsl:template match="level">
    <ol class="mir-toc-sections">
      <xsl:for-each select="item">

        <xsl:variable name="id" select="generate-id()" />

        <xsl:variable name="expanded">
          <xsl:choose>
            <xsl:when test="(../@expanded='first') and (position()=1)">true</xsl:when>
            <xsl:when test="../@expanded='first'">false</xsl:when>
            <xsl:otherwise><xsl:value-of select="../@expanded" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <li class="mir-toc-section">
          <xsl:choose>
            <!-- if there are deeper levels below, prepare expand/collapse functionality -->
            <xsl:when test="level|publications">

              <a href="#{$id}" data-bs-toggle="collapse" aria-expanded="{$expanded}" aria-controls="{$id}">
                <xsl:attribute name="class">
                  <xsl:choose>
                    <xsl:when test="$expanded='false'">mir-toc-section-toggle collapsed</xsl:when>
                    <xsl:otherwise>mir-toc-section-toggle</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <span>
                  <xsl:attribute name="class">
                    <xsl:text>toggle-collapse fas fa-fw </xsl:text>
                    <xsl:choose>
                      <xsl:when test="$expanded='true'">fa-chevron-down</xsl:when>
                      <xsl:otherwise>fa-chevron-right</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <span class="fas fa-fw fa-chevron-right" />
            </xsl:otherwise>
          </xsl:choose>

          <!-- show this level item -->
          <xsl:apply-templates select="." />

          <!-- show level/publications below the current one -->
          <xsl:if test="level|publications">
            <div id="{$id}">
              <xsl:attribute name="class">
                <xsl:text>mir-toc-section-content below collapse </xsl:text>
                <xsl:if test="$expanded='true'"> show</xsl:if>
              </xsl:attribute>
              <xsl:apply-templates select="level|publications" />
            </div>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <!-- show list of publications at current level -->
  <xsl:template match="publications">
    <ul class="mir-toc-section-list">
      <xsl:for-each select="doc">
        <xsl:sort select="@pos" data-type="number" order="ascending" />
        <li class="mir-toc-section-entry">
          <xsl:apply-templates select="." />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

</xsl:stylesheet>