class Services::General
  def self.arrays_intersect?( array1, array2 )
    (array1 & array2).length != 0
  end
end
