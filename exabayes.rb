class Exabayes < Formula
  desc "Large-scale Bayesian tree inference"
  homepage "http://sco.h-its.org/exelixis/web/software/exabayes/"
  url "http://sco.h-its.org/exelixis/material/exabayes/1.4.1/exabayes-1.4.1-src.tar.gz"
  sha256 "23e00b361a29365757e760b1acbb9d71744d2be5d9c450f8afdfaf5594d8994f"

  bottle do
    cellar :any
    revision 1
    sha256 "d018bac15a8658066a2b8225b7ea4a890a7beef0083b60f6f5c9bb5bbff16692" => :el_capitan
    sha256 "9e5ff9eb74e4bf5bb101969144c732f7860f6c199f139f3a1665432f00fec602" => :yosemite
    sha256 "cbd49207f24bf05034b681609abd84a90653f01dd4fb28846da5e593bc1ee27e" => :mavericks
  end

  head do
    url "https://github.com/aberer/exabayes.git", :branch => "devel"
    depends_on "autoconf" => :build
    depends_on "autoconf-archive" => :build
    depends_on "automake" => :build
  end

  # Fix: ./src/comm/PendingSwap.hpp:50:8: error: no type named 'unique_ptr' in namespace 'std'
  # ExaBayes needs std::unique_ptr, unordered_map, array
  needs :cxx11

  depends_on :mpi => [:cc, :cxx, :recommended]

  def install
    # Fix: ./src/comm/PendingSwap.hpp:50:8: error: no type named 'unique_ptr' in namespace 'std'
    ENV.libcxx
    args = %W[--disable-dependency-tracking --disable-silent-rules --prefix=#{prefix}]
    args << "--enable-mpi" if build.with? "mpi"
    system "autoreconf", "--install" if build.head?
    system "./configure", *args
    system "make", "install"
    pkgshare.install "examples", "manual"
  end

  def caveats; <<-EOS.undent
    The manual and example files are stored in
      #{opt_prefix}/share/exabayes
    EOS
  end

  test do
    cd testpath do
      (testpath/"config.nex").write <<-EOS.undent
        #nexus
        begin run;
          numgen 10000
          numruns 2
          numcoupledchains 2
          heatfactor 0.01
        end;
      EOS

      (testpath/"aln.phy").write <<-EOS.undent
         10 60
        Cow       ATGGCATATCCCATACAACTAGGATTCCAAGATGCAACATCACCAATCATAGAAGAACTA
        Carp      ATGGCACACCCAACGCAACTAGGTTTCAAGGACGCGGCCATACCCGTTATAGAGGAACTT
        Chicken   ATGGCCAACCACTCCCAACTAGGCTTTCAAGACGCCTCATCCCCCATCATAGAAGAGCTC
        Human     ATGGCACATGCAGCGCAAGTAGGTCTACAAGACGCTACTTCCCCTATCATAGAAGAGCTT
        Loach     ATGGCACATCCCACACAATTAGGATTCCAAGACGCGGCCTCACCCGTAATAGAAGAACTT
        Mouse     ATGGCCTACCCATTCCAACTTGGTCTACAAGACGCCACATCCCCTATTATAGAAGAGCTA
        Rat       ATGGCTTACCCATTTCAACTTGGCTTACAAGACGCTACATCACCTATCATAGAAGAACTT
        Seal      ATGGCATACCCCCTACAAATAGGCCTACAAGATGCAACCTCTCCCATTATAGAGGAGTTA
        Whale     ATGGCATATCCATTCCAACTAGGTTTCCAAGATGCAGCATCACCCATCATAGAAGAGCTC
        Frog      ATGGCACACCCATCACAATTAGGTTTTCAAGACGCAGCCTCTCCAATTATAGAAGAATTA
      EOS

      system *%W[#{bin}/yggdrasil -f aln.phy -m DNA -n test -s 100 -c config.nex -T 2]
      system *%W[#{bin}/sdsf -f ExaBayes_topologies.test.0 ExaBayes_topologies.test.1]
      system *%W[#{bin}/consense -n cons -f ExaBayes_topologies.test.0 ExaBayes_topologies.test.1]
    end
  end
end
