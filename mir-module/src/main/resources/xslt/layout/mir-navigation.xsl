<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="currentUser" select="document('notnull:user:current')" />

  <xsl:template match="/navigation//label">
  </xsl:template>

  <xsl:template match="/navigation//menu[@id and (group[item] or item)]">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:variable name="menuId" select="generate-id(.)" />
    <li class="nav-item dropdown">
      <a id="{$menuId}" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#">
      <xsl:if test="$active">
        <xsl:attribute name="class">
          <xsl:value-of select="'nav-link dropdown-toggle active'" />
        </xsl:attribute>
      </xsl:if>
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
        <xsl:when test="contains(@href,'change-current-user.xed?action=saveCurrentUser') and $currentUser/user/@locked='true'">
          <!-- Dont show the edit link if the user is no editable -->
        </xsl:when>
        <!-- item @type is "intern" -> add the web application path before the link -->
        <xsl:when test=" starts-with(@href,'http:') or starts-with(@href,'https:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')">
          <xsl:value-of select="@href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($WebApplicationBaseURL,substring-after(@href,'/'))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($url ) &gt; 0">
        <xsl:variable name="listItemClass">
          <xsl:text>mir-list-item</xsl:text>
          <xsl:if test="item">
            <xsl:text> dropdown-submenu</xsl:text>
          </xsl:if>
          <xsl:if test="$active">
            <xsl:text> active</xsl:text>
          </xsl:if>
        </xsl:variable>
        <li class="{$listItemClass}">
          <xsl:variable name="itemClass">
            <xsl:text>dropdown-item</xsl:text>
            <xsl:if test="item">
              <xsl:text> submenu dropdown-toggle</xsl:text>
            </xsl:if>
            <xsl:if test="$active">
              <xsl:text> active</xsl:text>
            </xsl:if>
          </xsl:variable>
          <a href="{$url}" class="{$itemClass}">
            <xsl:if test="@target">
              <xsl:copy-of select="@target" />
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

  <xsl:template match="/navigation//label" mode="footerMenu">
  </xsl:template>

  <xsl:template match="/navigation//item[@href]" mode="footerMenu">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]" />
    <xsl:param name="url">
      <xsl:choose>
        <xsl:when test="contains(@href,'change-current-user.xed?action=saveCurrentUser') and $currentUser/user/@locked='true'">
          <!-- Dont show the edit link if the user is no editable -->
        </xsl:when>
        <!-- item @type is "intern" -> add the web application path before the link -->
        <xsl:when test=" starts-with(@href,'http:') or starts-with(@href,'https:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')">
          <xsl:value-of select="@href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($WebApplicationBaseURL,substring-after(@href,'/'))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($url ) &gt; 0">
        <xsl:variable name="itemClasses">
          <xsl:value-of select="'nav-link'" />
          <xsl:if test="$active">
            <xsl:value-of select="' active'" />
          </xsl:if>
        </xsl:variable>
        <li>
          <xsl:attribute name="class">
            <xsl:copy-of select="$itemClasses" />
          </xsl:attribute>
          <a href="{$url}">
            <xsl:if test="@target">
              <xsl:copy-of select="@target" />
            </xsl:if>
            <xsl:apply-templates select="." mode="linkText" />
          </a>
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


  <xsl:template name="mir.generate_single_menu_entry">
    <xsl:param name="menuID" />
    <xsl:variable name="menuItem" select="$loaded_navigation_xml/menu[@id=$menuID]/item" />
    <li class="nav-item">
      <xsl:variable name="activeClass">
        <xsl:choose>
          <xsl:when test="$menuItem/@href = $browserAddress">
            <xsl:text>active</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>not-active</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="fullUrl">
        <xsl:call-template name="mir.resolveFullUrl">
          <xsl:with-param name="link" select="$menuItem/@href" />
        </xsl:call-template>
      </xsl:variable>
      <a id="{$menuID}" href="{$fullUrl}" class="nav-link {$activeClass}">
        <xsl:apply-templates select="$menuItem" mode="linkText" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="mir.resolveFullUrl">
    <xsl:param name="link" />
    <xsl:param name="appBaseUrl" select="$WebApplicationBaseURL" />
    <xsl:choose>
      <xsl:when test="starts-with($link,'http:')
                      or starts-with($link,'https:')
                      or starts-with($link,'mailto:')
                      or starts-with($link,'ftp:')">
        <xsl:value-of select="$link" />
      </xsl:when>
      <xsl:when test="starts-with($link,'/')">
        <xsl:choose>
          <xsl:when test="substring($appBaseUrl, string-length($appBaseUrl), 1) = '/'">
            <xsl:value-of
              select="concat(substring($appBaseUrl, 1, string-length($appBaseUrl) - 1), $link)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($appBaseUrl, $link)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring($appBaseUrl, string-length($appBaseUrl), 1) = '/'">
            <xsl:value-of select="concat($appBaseUrl, $link)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($appBaseUrl, '/', $link)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>