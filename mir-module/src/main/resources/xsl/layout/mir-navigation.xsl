<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/navigation//label">
  </xsl:template>
  <xsl:template match="/navigation//menu[@id and (group[item] or item)]">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:variable name="menuId" select="generate-id(.)" />
    <li class="nav-item dropdown">
      <xsl:if test="$active">
        <xsl:attribute name="class">
          <xsl:value-of select="'active'" />
        </xsl:attribute>
      </xsl:if>
      <a id="{$menuId}" class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
        <xsl:apply-templates select="." mode="linkText" />
      </a>
      <ul class="dropdown-menu" role="menu" aria-labelledby="{$menuId}">
        <xsl:apply-templates select="item|group" />
      </ul>
    </li>
  </xsl:template>
  <xsl:template match="/navigation//group[@id and item]">
    <xsl:param name="rootNode" select="." />
    <xsl:if test="name(preceding-sibling::*[1])='item'">
      <li role="presentation" class="dropdown-divider" />
    </xsl:if>
    <xsl:if test="label">
      <li role="presentation" class="dropdown-header">
        <xsl:apply-templates select="." mode="linkText" />
      </li>
    </xsl:if>
    <xsl:apply-templates />
    <li role="presentation" class="dropdown-divider" />
  </xsl:template>

  <xsl:template match="/navigation//item[@href]">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:param name="url">
      <xsl:choose>
        <!-- item @type is "intern" -> add the web application path before the link -->
        <xsl:when test=" starts-with(@href,'http:') or starts-with(@href,'https:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')">
          <xsl:value-of select="@href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="UrlAddSession">
            <xsl:with-param name="url" select="concat($WebApplicationBaseURL,substring-after(@href,'/'))" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($url ) &gt; 0">
        <xsl:variable name="itemClasses">
          <xsl:choose>
            <xsl:when test="item">
              <xsl:value-of select="'dropdown-submenu'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'dropdown-item'" />
              <xsl:if test="$active">
                <xsl:value-of select="' active'" />
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <li>
          <xsl:attribute name="class">
            <xsl:copy-of select="$itemClasses" />
          </xsl:attribute>
          <a href="{$url}">
            <xsl:if test="@target">
              <xsl:copy-of select="@target" />
            </xsl:if>
            <xsl:if test="item">
              <xsl:attribute name="class">
                <xsl:value-of select="'submenu dropdown-toggle dropdown-item'" />
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="." mode="linkText" />
          </a>
          <xsl:if test="item">
            <ul class="dropdown-menu" role="menu">
              <xsl:apply-templates select="item" />
            </ul>
          </xsl:if>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>
          <xsl:apply-templates select="." mode="linkText" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/navigation//*[label]" mode="linkText">
    <xsl:choose>
      <xsl:when test="label[lang($CurrentLang)] != ''">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label[lang($DefaultLang)]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>