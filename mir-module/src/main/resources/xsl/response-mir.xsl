<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="i18n mods str mcr acl mcrxsl">

  <xsl:template match="/response/result|/response/response[@subresult='groupOwner']/result|lst[@name='grouped']/lst[@name='returnId' and int[@name='matches']='0']" priority="10">
    <xsl:variable name="ResultPages">
      <xsl:if test="$hits &gt; 0">
        <xsl:call-template name="solr.Pagination">
          <xsl:with-param name="size" select="$rows" />
          <xsl:with-param name="currentpage" select="$currentPage" />
          <xsl:with-param name="totalpage" select="$totalPages" />
          <xsl:with-param name="class" select="'pagination-sm'" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <h1><xsl:value-of select="$PageTitle" /></h1>

<!-- Suchschlitz mit Suchbegriff, Treffer - Nummer, Vorschau, Autor, Änderungsdatum, Link zu den Details, Filter  -->
    <div class="row">
      <div class="col-lg-3">
        <h2><small>
          <xsl:choose>
            <xsl:when test="$hits=0">
              <xsl:value-of select="i18n:translate('results.noObject')" />
            </xsl:when>
            <xsl:when test="$hits=1">
              <xsl:value-of select="i18n:translate('results.oneObject')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="i18n:translate('results.nObjects',$hits)" />
            </xsl:otherwise>
          </xsl:choose>
        </small></h2>
      </div>

      <div class="col-lg-6">
        <div class="search_box">
          <form action="http://mir/vorlage_trefferliste" class="search_form" method="post">
            <div class="input-group input-group-sm">
              <div class="input-group-btn">
                <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" value="Alles" id="search_type_button"><span id="search_type_label">Alles</span> <span class="caret"></span></button>
                <ul class="dropdown-menu search_type">
                  <li><a href="#">Alles</a></li>
                  <li><a href="#">Titel</a></li>
                  <li><a href="#">Autor</a></li>
                  <li><a href="#">Name</a></li>
                  <li><a href="#">GND</a></li>
                  <li><a href="#">Alle Metadaten</a></li>
                  <li><a href="#">Volltext</a></li>
                </ul>
              </div>
              <input class="form-control" placeholder="ein oder mehrere Schlagworte" type="text" />
              <span class="input-group-btn">
                <button class="btn btn-primary" type="submit"><span class="glyphicon glyphicon-search"></span> Suchen</button>
              </span>
            </div>
          </form>
        </div>
      </div>

      <div class="col-lg-3">
      </div>
    </div> <!-- ENDE: Suchschlitz mit Suchbegriff -->

<!-- Filter, Pagination & Trefferliste -->
    <div class="row">
      <div class="col-lg-3">
        <h3>ToDo: Solr-Filter</h3>
      </div>
      <div class="col-lg-9">
        <xsl:copy-of select="$ResultPages" />
        <xsl:comment>
          RESULT LIST START
        </xsl:comment>
        <div id="hit_list">
          <xsl:apply-templates select="doc" />
        </div>
        <xsl:comment>
          RESULT LIST END
        </xsl:comment>
        <xsl:copy-of select="$ResultPages" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="doc[@objectType='mods']" priority="10" mode="resultList">
    <!--
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier" select="@id" />
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="mods-type">
      <xsl:choose>
        <xsl:when test="str[@name='mods.type']">
          <xsl:value-of select="str[@name='mods.type']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'article'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="hitCount" select="count(preceding-sibling::doc)+1" />
    <xsl:variable name="hitItemClass">
      <xsl:choose>
        <xsl:when test="$hitCount mod 2 = 1">odd</xsl:when>
        <xsl:otherwise>even</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',$identifier)" />
    <xsl:variable name="derivates" select="key('derivate', $identifier)" />

    <div class="hit_item {$hitItemClass}">
    <article class="result clearfix" itemscope="" itemtype="http://schema.org/Book">

      <div class="row">
        <div class="col-xs-2">
          <div class="hit_counter"><xsl:value-of select="$hitCount" /></div>
        </div>
        <div class="col-xs-7">
          <div class="hit_stars_5 hit_stars" title="ToDo: SolrScore"> <!-- ToDo: hit_stars_3 für nur 3 Sterne ... -->
            <div class="hit_star_1 hit_star"></div>
            <div class="hit_star_2 hit_star"></div>
            <div class="hit_star_3 hit_star"></div>
            <div class="hit_star_4 hit_star"></div>
            <div class="hit_star_5 hit_star"></div>
          </div>
        </div>
        <div class="col-xs-3">
          <div class="hit_options">
            <!-- add to basket -->
            <a class="hit_option hit_to_basket" href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer"
               title="{i18n:translate('basket.add')}"><span class="glyphicon glyphicon-shopping-cart"></span></a>

            <!-- download main document of first derivate -->
            <xsl:if test="not($derivates/str[@name='iviewFile']) and $derivates/str[@name='maindoc']">
              <xsl:variable name="derivid" select="$derivates/str[@name='maindoc'][1]/../str[@name='id']" />
              <xsl:variable name="maindoc" select="$derivates/str[@name='maindoc'][1]" />
              <xsl:variable name="fileType">
                <xsl:variable name="suffix" select="str:tokenize($maindoc,'.')[position()=last()]" />
                <xsl:choose>
                  <xsl:when test="$suffix='pdf'">
                    <xsl:value-of select="$suffix" />
                  </xsl:when>
                  <xsl:when test="contains($suffix,'doc')">
                    <xsl:value-of select="'docx'" />
                  </xsl:when>
                  <xsl:when test="contains($suffix,'xls')">
                    <xsl:value-of select="'xlsx'" />
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
              <xsl:variable name="derivifs" select="concat($derivbase,$maindoc,$HttpSession)" />
              <a class="hit_option hit_download" href="{$derivifs}" title="{$maindoc}"><span class="glyphicon glyphicon-download-alt"></span></a>
            </xsl:if>

            <!-- direct link to editor -->
            <xsl:if test="acl:checkPermission($identifier,'writedb')" >
              <xsl:variable name="editURL">
                <xsl:call-template name="mods.getObjectEditURL">
                  <xsl:with-param name="id" select="$identifier" />
                  <xsl:with-param name="layout" select="'$'" />
                  <xsl:with-param name="collection" select="'mods'" />
                </xsl:call-template>
              </xsl:variable>
              <a class="hit_option hit_edit"> <!-- ToDo: was genau soll passieren, wenn nicht bearbeitbar? -->
                <xsl:choose>
                  <xsl:when test="string-length($editURL) &gt; 0">
                    <xsl:attribute name="href">
                      <xsl:value-of select="$editURL" />
                    </xsl:attribute>
                    <xsl:attribute name="title">
                      <xsl:value-of select="i18n:translate('object.editObject')" />
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="href">
                      <xsl:value-of select="'#'" />
                    </xsl:attribute>
                    <xsl:attribute name="title">
                      <xsl:value-of select="i18n:translate('object.locked')" />
                    </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <span class="glyphicon glyphicon-pencil"></span>
              </a>
            </xsl:if>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12">
          <header class="top-head">
            <h3 class="hit_title shorten">
              <a href="{$linkTo}" itemprop="url" title="ToDo Maintitle">
                <span itemprop="name"><!-- ??? Muss das nicht Titel sein? -->
                  <xsl:choose>
                    <xsl:when test="./str[@name='search_result_link_text']">
                      <xsl:value-of select="./str[@name='search_result_link_text']" />
                    </xsl:when>
                    <xsl:when test="./str[@name='fileName']">
                      <xsl:value-of select="./str[@name='fileName']" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$identifier" />
                    </xsl:otherwise>
                  </xsl:choose>
                </span>
              </a>
            </h3>
          </header>
        </div>
      </div>

      <div class="row">
        <div class="col-xs-2">

          <aside class="Vorschaubild" itemtype="http://www.schema.org/ImageObject" itemscope="" itemprop="image">
            <xsl:choose>
              <xsl:when test="$derivates/str[@name='iviewFile']">
                <xsl:call-template name="iViewLinkPrev">
                  <xsl:with-param name="mcrid" select="$identifier" />
                  <xsl:with-param name="derivate" select="$derivates/str[@name='iviewFile']/../str[@name='id']" />
                  <xsl:with-param name="fileName" select="$derivates/str[@name='iviewFile'][1]" />
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="str:tokenize($derivates/str[@name='maindoc'][1],'.')[position()=last()] = 'pdf'">
                <xsl:variable name="filePath" select="concat($derivates/str[@name='id'][1],'/',mcr:encodeURIPath($derivates/str[@name='maindoc'][1]),$HttpSession)" />
                <img class="hit_icon" alt="{$mods-type}" title="thumbnail">
                  <xsl:attribute name="src">
                    <xsl:value-of select="concat($WebApplicationBaseURL,'img/pdfthumb/',$filePath,'?centerThumb=no')"/>
                  </xsl:attribute>
                </img>
              </xsl:when>
              <xsl:otherwise>
                <img class="hit_icon" src="{$WebApplicationBaseURL}images/icons/{$CurrentLang}/icon_{$mods-type}.png" itemprop="photo"
                  alt="{$mods-type}" />
              </xsl:otherwise>
            </xsl:choose>
    <!--    <a itemprop="url" href="images/microdata.jpg" title="Im Bildbetrachter öffnen"> -->
    <!--    </a> -->
          </aside>
        </div>
        <div class="col-xs-10">
          <xsl:if test="./arr[@name='mods.author']">
            <div class="hit_author shorten">
              <!-- section -->
                <xsl:for-each select="./arr[@name='mods.author']/str">
                  <xsl:if test="position()!=1">
                    <xsl:value-of select="' / '" />
                  </xsl:if>
                  <!-- address title="Author" -->
                    <a href="#" itemprop="author" itemscope="itemscope" itemtype="http://schema.org/Person" rel="author">
                      <span itemprop="name">
                        <xsl:value-of select="." />
                      </span>
                    </a>
                  <!-- /address -->
                </xsl:for-each>
              <!-- /section -->
            </div>
          </xsl:if>

          <div class="hit_type">
            <xsl:value-of select="./str[@name='mods.type']" />
          </div>

          <xsl:if test="./str[@name='parent']">
            <div class="hit_source shorten">
              <section>
                <xsl:text>aus: </xsl:text>
                <xsl:choose>
                  <xsl:when test="./str[@name='parentLinkText']">
                    <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',./str[@name='parent'])" />
                    <a href="{$linkTo}">
                      <xsl:value-of select="./str[@name='parentLinkText']" />
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="objectLink">
                      <xsl:with-param select="./str[@name='parent']" name="obj_id" />
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </section>
            </div>
          </xsl:if>
          <xsl:if test="str[@name='mods.dateIssued']|arr[@name='mods.publisher']">
            <div class="hit_date">
              <section>
                <span>
                  <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
                </span>
                <xsl:variable name="publisher" select="arr[@name='mods.publisher']/str" />
                <xsl:variable name="place" select="arr[@name='mods.place']/str" />
                <xsl:for-each select="$publisher">
                  <xsl:if test="position()!=1">
                    <xsl:value-of select="'; '" />
                  </xsl:if>
                  <span itemprop="publisher" itemscope="itemscope" itemtype="http://schema.org/Organize" title="Verlag">
                    <xsl:value-of select="$publisher" />
                  </span>
                </xsl:for-each>
                <xsl:if test="count($publisher)=1 and count($place)=1">
                  <xsl:value-of select="', '" />
                  <span itmeprop="addressRegion" itemscope="itemscope" itemtype="http://schema.org/PostalAddress" title="Ort">
                    <b>
                      <xsl:value-of select="$place" />
                    </b>
                  </span>
                </xsl:if>
                <xsl:if test="str[@name='mods.dateIssued']">
                  <xsl:variable name="date">
                    <xsl:value-of select="str[@name='mods.dateIssued']" />
                  </xsl:variable>
                  <xsl:if test="$publisher">
                    <xsl:value-of select="', '" />
                  </xsl:if>
                  <time pubdate="pubdate" datetime="{$date}" itemprop="datePublished" title="Erschienen">
                    <b>
                      <xsl:value-of select="$date" />
                    </b>
                  </time>
                </xsl:if>
              </section>
            </div>
          </xsl:if>

          <!-- abstract -->
          <xsl:variable name="description" select="str[@name='mods.abstract']" />
          <xsl:if test="$description">
            <section class="summary" title="summary">
              <div class="hit_source shorten" itemprop="description"> <!-- ToDo eigene Klasse! -->
                <xsl:value-of select="$description" />
              </div>
            </section>
          </xsl:if>

        </div>
      </div>


<!--
      <section>
        <span class="signature" title="Signatur">
          <span>
            Signatur :
          </span>
          <b>INF:HE:4000:HTML:Hog:2011</b>
        </span>
      </section>

      <xsl:variable name="description" select="str[@name='mods.abstract']" />
      <xsl:if test="$description">
        <section class="summary" title="summary">
          <p itemprop="description">
            <xsl:value-of select="$description" />
          </p>
        </section>
      </xsl:if>
      <footer class="date">
        <p>
          <xsl:variable name="dateModified" select="date[@name='modified']" />
          Zuletzt bearbeitet am :
          <time itemprop="dateModified" datetime="{$dateModified}">
            <xsl:call-template name="formatISODate">
              <xsl:with-param select="$dateModified" name="date" />
              <xsl:with-param select="i18n:translate('metaData.date')" name="format" />
            </xsl:call-template>
          </time>
        </p>
      </footer>
      <section class="files">
        <xsl:apply-templates select="." mode="hitInFiles" />
      </section>
      <section>
        <ul class="actions">
          <xsl:if test="acl:checkPermission($identifier,'writedb')" >
            <xsl:variable name="editURL">
              <xsl:call-template name="mods.getObjectEditURL">
                <xsl:with-param name="id" select="$identifier" />
                <xsl:with-param name="layout" select="'$'" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="string-length($editURL) &gt; 0">
                <li>
                  <a href="{$editURL}">
                    <i class="fa fa-edit"></i><xsl:value-of select="i18n:translate('object.editObject')" />
                  </a>
                </li>
              </xsl:when>
              <xsl:otherwise>
                <li>
                  <i class="fa fa-edit"></i><xsl:value-of select="i18n:translate('object.locked')" />
                </li>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <li>
            <a
              href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer">
              <i class="fa fa-plus"></i>
              <xsl:value-of select="i18n:translate('basket.add')" />
            </a>
          </li>
        </ul>
      </section> -->
      </article>
    </div>
  </xsl:template>

  <!-- copied from mods.xsl -> ToDo: refacture! -->
  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="mcrxsl:resourceAvailable('actionmappings.xml')">
      <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforCollection('update-xml',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforCollection('update',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforID('update-xml',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforID('update',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:variable name="urlWithParam">
              <xsl:call-template name="UrlSetParam">
                <xsl:with-param name="url" select="$url"/>
                <xsl:with-param name="par" select="'id'"/>
                <xsl:with-param name="value" select="$id" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="UrlAddSession">
              <xsl:with-param name="url" select="$urlWithParam" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:variable name="layoutSuffix">
          <xsl:if test="$layout != '$'">
            <xsl:value-of select="concat('-',$layout)" />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="form" select="concat('editor_form_commit-mods',$layoutSuffix,'.xml')" />
        <xsl:value-of select="concat($WebApplicationBaseURL,$form,$HttpSession,'?id=',$id)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>