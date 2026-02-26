<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrlayoututils="http://www.mycore.de/xslt/layoututils"
  xmlns:mcrstring="http://www.mycore.de/xslt/stringutils"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:strip-space elements="*" />
  <xsl:param name="numPerPage" />
  <xsl:param name="previousObject" />
  <xsl:param name="previousObjectHost" />
  <xsl:param name="nextObject" />
  <xsl:param name="nextObjectHost" />
  <xsl:param name="resultListEditorID" />
  <xsl:param name="page" />
  <xsl:param name="breadCrumb" />
  <xsl:param name="MCR.Metadata.Languages" select="'de'" />
  <xsl:param name="mcruser" select="document('user:current')/user"/>
  <xsl:param name="MIR.Layout.usermenu.realname.enabled" select="'false'"/>

  <xsl:include href="resource:xslt/layout/mir-layout-utils.xsl" />
  <xsl:include href="resource:xslt/layout/mir-navigation.xsl" />
  <xsl:include href="resource:xslt/mir-utils.xsl" />
  <xsl:variable name="loaded_navigation_xml" select="mcrlayoututils:get-personal-navigation()/navigation" />
  <xsl:variable name="browserAddress" select="mcrlayoututils:get-browser-address($loaded_navigation_xml,.)" />
  <xsl:variable name="whiteList" select="concat($ServletsBaseURL,'MCRLoginServlet')" />
  <xsl:variable name="readAccess">
    <xsl:choose>
      <xsl:when test="starts-with($RequestURL, $whiteList)">
        <xsl:value-of select="'true'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="mcrlayoututils:read-access($browserAddress,())" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:template name="mir.loginMenu">
    <xsl:variable name="loginURL"
      select="concat( $ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri( string( $RequestURL ) ) )" />
    <xsl:choose>
      <xsl:when test="contains($RequestURL, 'MCRLoginServlet') and mcracl:is-current-user-guest-user()"></xsl:when>
      <xsl:when test="mcracl:is-current-user-guest-user()">
        <li class="nav-item">
          <a id="loginURL" class="nav-link" href="{$loginURL}">
            <xsl:value-of select="mcri18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="nav-item dropdown">
          <a id="currentUser" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#">
            <xsl:if test="$loaded_navigation_xml/menu[@id='user']//item[@href = $browserAddress ]">
              <xsl:attribute name="class">
                <xsl:value-of select="'nav-link dropdown-toggle active'" />
              </xsl:attribute>
            </xsl:if>
            <strong>
              <xsl:choose>
                <xsl:when test="$MIR.Layout.usermenu.realname.enabled != 'true'">
                  <xsl:value-of select="$mcruser/@name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$mcruser/realName">
                      <xsl:value-of select="$mcruser/realName"/>
                    </xsl:when>
                    <xsl:when test="$mcruser/eMail">
                      <xsl:value-of select="$mcruser/eMail"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$mcruser/@name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </strong>
            <span class="caret" />
          </a>
          <ul class="dropdown-menu" role="menu">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='user']/*" />
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.languageMenu">
    <xsl:variable name="availableLanguages" select="tokenize($MCR.Metadata.Languages,',')" />
    <xsl:if test="count($availableLanguages) &gt; 1">
      <xsl:variable name="curLang" select="document(concat('language:',$CurrentLang))" />
<!--       <language termCode="deu" biblCode="ger" xmlCode="de"> -->
<!--         <label xml:lang="de">Deutsch</label> -->
<!--         <label xml:lang="en">German</label> -->
<!--       </language> -->
      <li class="nav-item dropdown mir-lang">
        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" title="{mcri18n:translate('mir.language.change')}">
          <xsl:value-of select="$curLang/language/@xmlCode" />
          <span class="caret" />
        </a>
        <ul class="dropdown-menu language-menu" role="menu">
          <xsl:for-each select="$availableLanguages">
            <xsl:variable name="lang"><xsl:value-of select="mcrstring:trim(.)" /></xsl:variable>
            <xsl:if test="$lang!='' and $CurrentLang!=$lang">
              <xsl:variable name="langDef" select="document(concat('language:',$lang))" />
              <li>
                <xsl:variable name="langURL">
                  <xsl:call-template name="mir.languageLink">
                    <xsl:with-param name="lang" select="$langDef/language/@xmlCode" />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="langTitle">
                  <xsl:apply-templates select="$langDef/language" mode="mir.langTitle" />
                </xsl:variable>
                <a href="{$langURL}" class="dropdown-item" title="{$langTitle}">
                  <xsl:value-of select="$langDef/language/@xmlCode" />
                </a>
              </li>
            </xsl:if>
          </xsl:for-each>
        </ul>
      </li>
    </xsl:if>
  </xsl:template>
  <xsl:template match="language" mode="mir.langTitle">
    <xsl:variable name="code" select="@xmlCode" />
    <xsl:choose>
      <xsl:when test="label[lang($code)]">
        <xsl:value-of select="label[lang($code)]" />
      </xsl:when>
      <xsl:when test="label[lang($CurrentLang)]">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </xsl:when>
      <xsl:when test="label[lang($DefaultLang)]">
        <xsl:value-of select="label[lang($DefaultLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xmlCode" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="mir.languageLink">
    <xsl:param name="lang" />
    <xsl:value-of select="mcrurl:set-param($RequestURL, 'lang', $lang)" />
  </xsl:template>

  <xsl:template name="mir.breadcrumb">

    <!-- get href of starting page -->
    <!--
      Variable beinhaltet die url der in navigation.xml angegebenen
      Startseite
    -->
    <xsl:variable name="hrefStartingPage"
      select="$loaded_navigation_xml/@hrefStartingPage" />
    <!-- END OF: get href of starting page -->

    <!--
      fuer jedes Element des Elternknotens <navigation> in
      navigation.xml
    -->
    <xsl:for-each select="$loaded_navigation_xml//item[@href]">
      <!-- pruefe ob ein Element gerade angezeigt wird -->
      <xsl:if test="@href = $browserAddress ">
        <!-- fuer sich selbst und jedes seiner Elternelemente -->
        <xsl:for-each select="ancestor-or-self::item">
          <!--
            und fuer alle Seiten ausser der Startseite zeige den
            Seitentitel in der Navigationsleiste Verweis auf die
            Startseite existiert bereits s.o.
          -->
          <xsl:if test="$browserAddress != $hrefStartingPage ">
            <li class="breadcrumb-item">
              <xsl:choose>
                <xsl:when test="@href = $browserAddress">
                  <xsl:attribute name="class">active </xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="./label[lang($CurrentLang)] != ''">
                      <xsl:value-of select="ancestor::menu/label[lang($CurrentLang)]" />:
                      <xsl:value-of select="./label[lang($CurrentLang)]" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="./label[lang($DefaultLang)]" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{concat($WebApplicationBaseURL,substring-after(@href,'/'))}">
                    <xsl:choose>
                      <xsl:when test="./label[lang($CurrentLang)] != ''">
                        <xsl:value-of select="./label[lang($CurrentLang)]" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="./label[lang($DefaultLang)]" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </li>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================================================== -->
  <xsl:template name="mir.write.content">
    <xsl:call-template name="print.writeProtectionMessage" />
    <xsl:choose>
      <xsl:when test="$readAccess='true'">
        <!-- xsl:call-template name="getFastWCMS" / -->
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mir.printNotLoggedIn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.basketMenu">
    <xsl:variable name="basketType" select="'objects'" />
    <xsl:variable name="basket" select="document(concat('basket:',$basketType))/basket" />
    <xsl:variable name="entryCount" select="count($basket/entry)" />
    <xsl:variable name="basketTitle">
      <xsl:choose>
        <xsl:when test="$entryCount = 0">
          <xsl:value-of select="mcri18n:translate('basket.numEntries.none')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:when test="$entryCount = 1">
          <xsl:value-of select="mcri18n:translate('basket.numEntries.one')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcri18n:translate-with-params('basket.numEntries.many',$entryCount)" disable-output-escaping="yes" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <li class="dropdown" id="basket-list-item">
      <a class="dropdown-toggle nav-link" data-bs-toggle="dropdown" href="#" title="{$basketTitle}">
        <i class="fas fa-bookmark"></i>
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu">
        <li>
          <a href="{$ServletsBaseURL}MCRBasketServlet?type={$basket/@type}&amp;action=show" class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

  <xsl:template name="mir.prop4js">
    <script>
      <xsl:text>var webApplicationBaseURL = '</xsl:text>
      <xsl:value-of select="$WebApplicationBaseURL" />
      <xsl:text>';</xsl:text>
      <xsl:text>var currentLang = '</xsl:text>
      <xsl:value-of select="$CurrentLang" />
      <xsl:text>';</xsl:text>
    </script>
    <script>
      window["mycoreUploadSettings"] = {
      webAppBaseURL:"<xsl:value-of select='$WebApplicationBaseURL' />"
      }
    </script>
    <script src="{$WebApplicationBaseURL}js/mir/session-polling.js"></script>
    <script src="{$WebApplicationBaseURL}js/mir/sherpa.js"></script>
    <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-api.js"></script>
    <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-gui.js"></script>
    <script src="{$WebApplicationBaseURL}js/mir/ror-search.min.js"/>
    <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}modules/webtools/upload/css/upload-gui.css" />
  </xsl:template>

  <xsl:template name="print.statusMessage" >
    <xsl:variable name="XSL.Status.Message" select="mcrurl:get-param($RequestURL, 'XSL.Status.Message')" />
    <xsl:variable name="XSL.Status.Style" select="mcrurl:get-param($RequestURL, 'XSL.Status.Style')" />
    <xsl:if test="string-length($XSL.Status.Message) &gt; 0">
      <div class="row">
        <div class="col-md-12">
          <div role="alert">
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="string-length($XSL.Status.Style) &gt; 0"><xsl:value-of select="concat('alert-', $XSL.Status.Style)" /></xsl:when>
                <xsl:otherwise>alert-info</xsl:otherwise>
              </xsl:choose>
              alert alert-dismissible fade show
            </xsl:attribute>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            <span aria-hidden="true"><xsl:value-of select="mcri18n:translate($XSL.Status.Message)" /></span>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
